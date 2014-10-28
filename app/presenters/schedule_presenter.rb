# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter

  attr_accessor :visible

  def initialize( schedule, options={} )
    @schedule = SimpleDelegator.new(schedule)
    @visible = options[:visible] || true
  end

  # human readable shift time
  def shift_time
    "#{schedule.start_time.to_s(:short)} to #{schedule.end_time.to_s(:short)}"
  end

  # true when the date falls within the schedule's start and end times
  #  AND when the schedule has that day of week selected. Does not consider
  #  whether the schedule is active
  def shift_on_date?( date )
    date.between?(schedule.start_date, schedule.end_date) \
    && schedule.send(date.strftime('%A').downcase)
  end

  def schedule
    @schedule.__getobj__
  end

  def schedule=(new_sched)
    @schedule.__setobj__ (new_sched)
  end

  def to_s
    schedule.to_s
  end
end