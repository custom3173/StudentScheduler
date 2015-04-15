# presenter code to wrap schedules in a
#  display friendly format
class SchedulePresenter < ApplicationPresenter
  include Schedulable

  # print human friendly date string
  # TODO: heavy duplication with ScheduleCalendar, think about
  # moving into monkey patch or helper code (or something)
  def pretty_dates
    _start = self.start_date
    _end = self.end_date
    if _start == _end
      "#{_start.strftime '%b %-d, %Y'}"
    elsif _start.month == _end.month
      "#{_start.strftime '%b %-d'} - #{_end.strftime '%-d, %Y'}"
    elsif _start.year == _end.year
      "#{_start.strftime '%b %-d'} - #{_end.strftime '%b %-d, %Y'}"
    else
      "#{_start.strftime '%b %-d, %Y'} - #{_end.strftime '%b %-d, %Y'}"
    end
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