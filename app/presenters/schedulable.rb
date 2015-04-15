# A concern for schedule-like objects, namely ScheduleGroup and
#  SchedulePresenter. The mixin dries the code and models
#  behavior better than a classic inheritance could allow.
module Schedulable
  extend ActiveSupport::Concern

  #### presentation

  # human readable shift printouts
  def shift_begin
    format = (self.start_time.min == 0 ? :hour : :short)
    self.start_time.to_s(format)
  end

  def shift_end
    format = (self.end_time.min == 0 ? :hour : :short)
    self.end_time.to_s(format)
  end

  def shift_time
    "#{shift_begin} to #{shift_end}"
  end

  # minutes from the beginning of the day
  def offset
    self.start_time.hour*60 + self.start_time.min
  end

  ### comparison / eval

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
end