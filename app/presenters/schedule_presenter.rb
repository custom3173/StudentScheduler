# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter < ApplicationPresenter

  attr_accessor :visible, :cid

  def initialize( sched, options={} )
    @visible = options[:visible] || true
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

  # true when two schedules' shift times overlap each other
  #  does not consider dates, only times
  def overlaps?( other, options={} )
    # require that the schedules belong to the same person
    options[:match_owner] ||= false

    # add buffer to ensure that schedules have
    #  adequate time between them (in minutes)
    buf = options[:buffer] || 0

    if options[:match_owner]
      return false unless self.student.id == other.student.id
    end

    if self.start_time <= (other.end_time + buf.minutes) &&
      (self.end_time + buf.minutes) >= other.start_time
      true
    else false
    end
  end

  # only render JSON elements that the view cares about
  def as_json( options={} )
    super( only: [:start_time, :end_time, :id] )
    .merge(visible: self.visible, cid: self.cid)
  end

  def schedule
    model
  end
end