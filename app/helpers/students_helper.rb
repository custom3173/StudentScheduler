module StudentsHelper

  # helper class holds processed schedules in format to make them more
  #  readily displayed on the calendar
  class ScheduleData

    include Comparable

    attr_accessor :name, :time, :sibling, :description, :visible

    def initialize(name, time, arriving, permanent, absent, current_day=false, starting_schedule, description)
      @name = name               # the student's name (shortened)
      @time = time               # time time that this schedule includes
      @permanent = permanent     # true when this is a long-term schedule
      @arriving = arriving       # true when arriving to work, false when leaving
      @absent = absent           # true when absent from work, false when present
      @current_day = current_day # this is the date requested by the user (for css handling)
      @visible = true
      @starting_schedule = starting_schedule # true when this is the first schedule of a pair
      @description = description
      @reverse_display = false
      @sibling = nil
    end

    def permanent?
      @permanent
    end

    def temporary?
      !self.permanent?
    end

    def arriving?
      @arriving
    end

    def leaving?
      !self.arriving?
    end

    def absent?
      @absent
    end

    def present?
      !self.absent?
    end

    def starting_schedule?
      @starting_schedule
    end

    # changes the output flags (ie css_classes result)
    #  of two schedules if one schedule is modified by an
    #  absent schedule
    def process_absence (absent_schedule)
      if @absent != absent_schedule.absent? and @name == absent_schedule.name
        # _starting_schedule is the first schedule of a matched pair
        self.starting_schedule? ? _starting_schedule = self : _starting_schedule = self.sibling

        # the schedules have intersecting time slots, i.e the absent schedule exists inside the normal schedule
        #    outside the normal if block so it doesn't grab more specific staggered schedules
        if absent_schedule > _starting_schedule and absent_schedule < _starting_schedule.sibling
          absent_schedule.absent_toggle
        end

        # the schedules fall on the same time slot
        #  mark the original schedule as invisible
        #  and display only the absent schedule
        if self == absent_schedule
          @visible = false

        # a normal schedule exists inside of an absent schedule
        # mark the normal schedule as invisible
        elsif absent_schedule < _starting_schedule and absent_schedule.sibling > _starting_schedule.sibling
          @visible = false

        # staggered schedule, absence begins before regular schedule, ends before the end of regular schedule
        #  only sets the beginning regular schedule invisible, absence already toggled (reversed) by intersection calc.
        elsif absent_schedule < _starting_schedule and absent_schedule.sibling > _starting_schedule and absent_schedule.sibling < _starting_schedule.sibling
          _starting_schedule.visible = false

        # staggered schedule, absence begins after regular schedule, ends after the end of regular schedule
        #  only sets the ending regular schedule invisible, absence already toggled (reversed) by intersection calc.
        elsif absent_schedule > _starting_schedule and absent_schedule < _starting_schedule.sibling and absent_schedule.sibling > _starting_schedule.sibling
          _starting_schedule.sibling.visible = false
        end
      end
    end

    def reverse_display?
      @reverse_display
    end

    # quick toggle for absent/permanent processing
    #  @reverse_display allows css_classes to change
    #  classes when absent calculation dictates
    def absent_toggle
      @reverse_display = true
    end

    # turn visibility on and off
    def visible_toggle
      @visible = !@visible
    end

    # returns a string of css classes that apply to this object to be dumped directly into html
    def css_classes
      # populate the output array
      output = Array.new   # an array of strings to give a handle on the elements for css
      output.push('invisible') if !@visible      # tell css not to render invisible elements (caused by absent schedules)
      output.push('current-day') if @current_day # true when the date of display matches this day
      (@arriving ^ @reverse_display) ? output.push('arriving') : output.push('leaving')
      if @permanent
        output.push('permanent')
      elsif @absent and !@reverse_display
        output.push('absent')
      else
        output.push('temporary')
      end
      output.join(' ')
    end

    # direct comparisons of the class only refer to the time attribute
    def <=>(other)
      @time <=> other.time
    end

    def to_s # nice and pretty for final display
      @arriving ^ @reverse_display ? "#@name" : "#@name"
    end
  end

  def process_schedules_for_display (schedules, requested_date)

    # temporary array to hold preprocessed schedules
    schedules_tmp = Array.new

    # populate the processing array with ScheduleData objects
    c = 1 # counts the days to find the current day
    for schedule_day in schedules do  # every schedule by day (e.g. Mon, Tues etc.)
      schedules_tmp << Array.new
      for schedule in schedule_day do # the individual schedules
        schedules_tmp.last << ScheduleData.new(schedule.student.short_name, schedule.start_time,
                                               true, schedule.permanent, schedule.absent,
                                               c == requested_date.wday, true, schedule.description)
        schedules_tmp.last << ScheduleData.new(schedule.student.short_name, schedule.end_time,
                                               false, schedule.permanent, schedule.absent,
                                               c == requested_date.wday, false, schedule.description)
        # set the sibling attributes
        schedules_tmp.last[-1].sibling, schedules_tmp.last[-2].sibling = schedules_tmp.last[-2], schedules_tmp.last[-1]
      end
      c += 1 # increment day counter
      c = 0 if c == 7 # correction for the way Date.wday counts days
    end

    # process the absences and edit existing schedules to display properly
    for day in schedules_tmp do
      for schedule1 in day do
        day.each { |schedule2| schedule2.process_absence(schedule1) } if schedule1.absent?
      end
    end

    # hash tracks the time slots that will be needed in the final array
    time_slots = Hash.new

    # determine the existing time slots
    for day in schedules_tmp do
      for schedule in day do
        _time = schedule.time.strftime("%-I:%M %p")
        time_slots.has_key?(_time) ? time_slots[_time] += 1 : time_slots[_time] = 0
      end
    end

    # populate the return structure
    processed_schedules = Array.new  # return array
    c1, c2 = 0, 0
    for key, value in time_slots do
      processed_schedules << Array.new
      for day in schedules_tmp do
        processed_schedules[c1] << Array.new
        for schedule in day do
          processed_schedules[c1][c2] << schedule if key == schedule.time.strftime("%-I:%M %p")
        end
        c2 += 1
      end
      c1 += 1
      c2 = 0
    end

    # final row sort before returning
    processed_schedules.sort do |row1, row2|
      row1.flatten.compact.first.time <=> row2.flatten.compact.first.time
    end
  end
end
