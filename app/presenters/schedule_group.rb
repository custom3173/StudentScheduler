# a schedule group represents a collection
#  of schedules treated as one element in the calendar
# ScheduleGroups have overlapping start and end times and
#  always belong to a single user. They are given a unique
#  id at creation for js and css styling
class ScheduleGroup

  Shift = Struct.new( :time, :group, :type )

  attr_reader :schedules, :student, :start_time, :end_time

  def initialize( *schedules )
    @schedules = Array(schedules)
    @student = @schedules.first.student
    @start_time = schedules.min_by(&:start_time).start_time
    @end_time = schedules.max_by(&:end_time).end_time
    @shifts = nil
    _check_owner schedules
  end

  # take a list of schedules and return a sorted
  #  list of ScheduleGroups
  def self.group( schedules )
    # handle nil and empty arrays
    unless Enumerable === schedules && schedules.length > 0
      return nil
    end

    schedules.sort_by!(&:start_time)
    init = ScheduleGroup.new schedules.shift

    schedules.reduce([init]) do |acc, s|
      if s.overlaps? acc.last 
        acc.last << s
      else
        acc << ScheduleGroup.new(s)
      end
      acc
    end
  end

  # the collected start and end times for the schedules.
  #
  # NOTE: Shifts overwrite each other according to their ordinal value
  #        from the model, ie Absent > Temporary > Regular. This
  #        might have to change if more schedule types are added.
  def shifts
    @shifts || @shifts = _calculate_shifts
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

  # Groups overlap another schedule (or group)
  #  when any of their child schedules overlap
  #
  # TODO: take advantage of start_time and end_time
  #  so this isn't so inefficient
  def overlaps?( other, options={} )
    options.merge! match_owner: true
    @schedules.find { |s| s.overlaps? other, options }
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
    out.each_with_index.map do |e, i|
      time_format = (e.time.min == 0 ? :hour : :short)
      { 
        id: i,
        time: e.time.to_s(time_format),
        type: e.type,
        group: Schedule.groups.invert[e.group]
      }
    end
  end
end