# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter < ApplicationPresenter
  include Schedulable

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