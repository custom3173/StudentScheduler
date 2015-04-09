# a schedule group represents a collection
#  of schedules treated as one element in the calendar
# ScheduleGroups have overlapping start and end times and
#  always belong to a single user. They are given a unique
#  id at creation for js and css styling
class ScheduleGroup
  include Schedulable
  include ActiveModel::Serializers::JSON

  Shift = Struct.new( :time, :group, :type )

  attr_accessor :overlapping, :overlapped_by
  attr_reader :schedules, :student, :start_time, :end_time

  def initialize( *schedules )
    @schedules  = Array(schedules)
    @student    = @schedules.first.student
    _check_owner schedules

    @start_time = schedules.min_by(&:start_time).start_time
    @end_time   = schedules.max_by(&:end_time).end_time
    @shifts     = nil
    @overlapping   = 0
    @overlapped_by = 0
  end

  # take a list of schedules and return a sorted
  #  list of ScheduleGroups
  def self.group( schedules )
    # handle nil and empty arrays
    return nil unless Enumerable === schedules && schedules.length > 0

    schedules.sort_by!(&:start_time)

    # todo: comments
    out = Array( ScheduleGroup.new schedules.shift )
    schedules.reduce( out.clone ) do |lst, s|
      match = lst.find { |l| l.overlaps? s, match_owner: true }
      if match
        match << s
        lst
      else
        new_group = ScheduleGroup.new s
        out << new_group
        intersection = lst.select { |l| l.overlaps? new_group, buffer: 30 }
        intersection.each { |e| e.overlapped_by += 1 }
        new_group.overlapping = intersection.length
        intersection << new_group
      end
    end
    out
  end

  # the collected start and end times for the schedules.
  #
  # NOTE: Shifts overwrite each other according to their ordinal value
  #        from the model, ie Absent > Temporary > Regular. This
  #        might have to change if more schedule types are added.
  def shifts
    @shifts || @shifts = _calculate_shifts
  end

  # simpler shift display. Returns an array of strings noting
  #  start/end for working shifts only. Absent shifts are 
  #  subtracted from the working shifts, but not included
  #  in the final result
  def compact_shifts
    shifts = self.shifts
    start = nil

    shifts.reduce([]) do |compact, shift|
      if shift[:group] != 'absent' && shift[:type] != :end
        start ||= shift[:time]
      elsif start # not nil
        compact << "#{start} - #{shift[:time]}"
        start = nil
      end
      compact
    end
  end

  # append schedules like the group is an array
  def <<( other )
    case other
    when SchedulePresenter
      _check_owner other
      _set_times other
      @schedules << other
    when ScheduleGroup
      self.merge! other
    else
      raise ArgumentError,
        "#{other} is not a SchedulePresenter or ScheduleGroup"
    end
    @shifts = nil
    self
  end

  # merge in another schedule group
  def merge!( other_group )
    _check_owner other_group
    _set_times other_group
    @schedules = @schedules + other_group.schedules
    @shifts = nil
    self
  end

  # updates the ScheduleGroups' overlap tracking attributes
  #  whenever self overlaps with other_group
  def overlaps!( other_group, options={} )
    if self.overlaps? other_group, options
      if @start_time <= other_group.start_time
        other_group.overlapped_by += 1
        self.overlapping += 1
      else
      end

    end
  end

  def attributes
    { 'start_time' => nil, 'end_time' => nil, 'shifts' => nil }
  end


  private

  def _check_owner( other )
    (Array other).each do |obj|
      unless self.student.id == obj.student.id
        raise ArgumentError,
              "Schedule owners do not match for #{self} and #{obj}"
      end
    end
  end

  def _set_times( schedule )
    @start_time = schedule.start_time if schedule.start_time < @start_time
    @end_time   = schedule.end_time   if schedule.end_time   > @end_time
  end

  def _calculate_shifts
    shift_segments = @schedules.reduce([]) do |acc, s|
      acc << Shift.new( s.start_time, Schedule.groups[s.group], :start )
      acc << Shift.new( s.end_time, Schedule.groups[s.group], :end )
    end

    shift_segments.sort_by!(&:time)

    out = [ shift_segments.shift ]
    counter = Hash.new(0)
    counter[ out.first.group ] += 1

    shift_segments.each do |seg|
      if seg.type == :start
        counter[ seg.group ] += 1
        out << seg if out.last.group < seg.group

      elsif seg.type == :end
        counter[ seg.group ] -= 1
        if counter[ out.last.group ] == 0
          next_group = counter.max_by { |grp, cnt| cnt == 0 ? 0 : grp }.first
          out << Shift.new( seg.time, next_group, :start)
        end
      end
    end

    # replace structs with hash values and clean up output for display
    out.last.type = :end
    out.map!.each_with_index do |e, i|
      time_format = (e.time.min == 0 ? :hour : :short)
      length = (e.type == :start ? (out[i+1].time - e.time) / 60 : 0)

      { 
        id: i,
        time: e.time.to_s(time_format).chop,
        length: length,
        type: e.type,
        group: Schedule.groups.invert[e.group]
      }
    end
    # eliminate zero-length start tags
    out.reject { |e| e[:type] == :start && e[:length].zero? }
  end
end