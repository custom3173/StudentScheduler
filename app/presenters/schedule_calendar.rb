# A presenter that handles the calendar view
#  code. Isn't truly a delegated class but it makes
#  sense to leave it here for now.

class ScheduleCalendar

  attr_reader   :schedules_by_date, :type, :date, :offset,
                  :cal_begin, :cal_end

  # date: string representation of date
  # type: string or sym in [day, week, month]
  def initialize( options = {} )
    self.date = options[:date]
    self.type = options[:type] || :week
    @schedules_by_date = {}

    load!
  end

  # get the appropriate schedules from model
  def load!

    # check for valid setup before making queries
    unless @cal_begin.acts_like?(:date) && @cal_end.acts_like?(:date)
      raise StandardError, "Set valid date and type first"
    end

    raw = SchedulePresenter.wrap(Schedule.in_date_range(@cal_begin, @cal_end))

    # set the offset (in minutes) from the earliest schedule
    #  so the view can eliminate excess whitespace
    earliest_time = raw.min_by(&:start_time).start_time
    @offset = earliest_time.hour*60 + earliest_time.min

    # group by each date and assign ids
    cntr = 0
    (@cal_begin..@cal_end).each do |date|
      @schedules_by_date[date] = raw.select { |s| s.shift_on_date? date }
      @schedules_by_date[date].map! do |s| 
        s.cid = (cntr += 1) # schedules need unique ids
        s.clone             # deep copy, again for unique ids
      end
    end

    # group overlapping schedules belonging to the same user
    
  end

  # depends on date being set
  def type=( new_type )

    # check that @date quacks like a date
    unless @date.acts_like? :date
      raise StandardError, "Invalid date set: #{@date}"
    end

    new_type = new_type.to_sym
    case new_type
    when :day
      @cal_begin, @cal_end = @date, @date
    when :week
      @cal_begin = @date.beginning_of_week - 1.day
      @cal_end   = @date.end_of_week - 1.day
    when :month
      @cal_begin = @date.beginning_of_month
      @cal_end   = @date.end_of_month
    else raise ArgumentError, "Invalid calendar type: #{new_type}"
    end

    @type = new_type
  end

  # expects a date string and attempts to parse it
  #  assigns a DateTime/Date object to the instance
  def date=( date_str )
    begin # try to parse the date string
      @date = DateTime.parse date_str
    rescue StandardError
      @date = Date.today
    end
  end
end