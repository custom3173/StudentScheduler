# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter < ApplicationPresenter

  attr_accessor :visible

  def initialize( sched, options={} )
    @visible = options[:visible] || true
    super(sched)
  end

  # human readable shift printouts
  def shift_begin
    "#{start_time.to_s(:short)}"
  end

  def shift_end
    "#{end_time.to_s(:short)}"
  end

  def shift_time
    "#{shift_begin} to #{shift_end}"
  end

  # true when the date falls within the schedule's start and end times
  #  AND when the schedule has that day of week selected. Does not consider
  #  whether the schedule is active
  def shift_on_date?( date )
    date.between?(start_date, end_date) \
    && schedule.send(date.strftime('%A').downcase)
  end

  def schedule
    model
  end
end