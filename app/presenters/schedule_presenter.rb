# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter < ApplicationPresenter

  attr_accessor :visible, :cid

  def initialize( sched, cid, options={} )
    @visible = options[:visible] || true
    @cid = cid # the calendar's id
    super(sched)
  end

  # human readable shift printouts
  def shift_begin
    format = (start_time.min == 0 ? :hour : :short)
    "#{start_time.to_s(format)}"
  end

  def shift_end
    format = (end_time.min == 0 ? :hour : :short)
    "#{end_time.to_s(format)}"
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

  # only render JSON elements that the view cares about
  def as_json( options={} )

    super( only: [:id] )
  end

  def schedule
    model
  end
end