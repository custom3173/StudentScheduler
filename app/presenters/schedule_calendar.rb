# A presenter that handles the calendar view
#  code. Isn't truly a delegated class but it makes
#  sense to leave it here for now.

class ScheduleCalendar

  attr_reader   :schedules_by_date, :students, :type, :date, :offset,
                  :cal_begin, :cal_end, :previous, :next, :date_label

  # date: :today or string representation of date
  # type: string or sym in [day, week, month]
  def initialize( options = {} )

    # try to parse the date string
    begin
      @date = (options[:date] == :today ? Date.today : options[:date].to_date)
    rescue StandardError
      @date = Date.today
    end

    # verify the type is valid and set the
    #  calendar start and end dates
    type = (options[:type] || :week).to_sym
    case type
    when :day
      @cal_begin, @cal_end = @date, @date
    when :week # correct for sunday to be start of the week
      if @date.sunday? 
        @cal_begin = @date
        @cal_end   = @date + 6.days
      else
        @cal_begin = @date.beginning_of_week - 1.day
        @cal_end   = @date.end_of_week - 1.day
      end
    when :month
      @cal_begin = @date.beginning_of_month.beginning_of_week(:sunday)
      @cal_end   = @date.end_of_month.end_of_week(:sunday)
    else raise ArgumentError, "Invalid calendar type: #{type}"
    end

    # set the calendar type, start and end dates
    #  and the dates of the next and previous calendar
    #  of the same type
    @type          = type
    @previous      = self.get_previous_date
    @next          = self.get_next_date
    @date_label    = self.get_date_interval

    load!
  end

  ### presentation helpers ###

  # intelligent and concise label for the date
  #   range that accounts for the display type
  def get_date_interval
    case @type
    when :day
      @date.strftime "%A, %b %-d, %Y"
    when :week
      if @cal_begin.month == @cal_end.month
        "#{@cal_begin.strftime '%b %-d'} - #{@cal_end.strftime '%-d, %Y'}"
      elsif @cal_begin.year == @cal_end.year
        "#{@cal_begin.strftime '%b %-d'} - #{@cal_end.strftime '%b %-d, %Y'}"
      else
        "#{@cal_begin.strftime '%b %-d, %Y'} - #{@cal_end.strftime '%b %-d, %Y'}"
      end
    when :month
      @date.strftime "%B %Y"
    end
  end

  # get a date from the previous interval range
  def get_previous_date
    @date - 1.send(@type)
  end

  # get a date from the next interval
  def get_next_date
    @date + 1.send(@type)
  end

  # get class selectors to distinguish important days
  def date_classes(date)
    selectors = []
    selectors << 'td' if date == Date.today
    if date < @date.beginning_of_month || date > @date.end_of_month
      selectors << 'not-month'
    end
    selectors << 'cal-day'
  end


  ### nuts and bolts

  # get the appropriate schedules from model
  def load!
    @schedules_by_date = {}
    # empty array for dates with no schedules
    @schedules_by_date.default = []

    # load schedules and wrap with presenter
    raw = Schedule.includes(:student).in_date_range(@cal_begin, @cal_end)
    raw = SchedulePresenter.wrap raw

    # get a unique sorted list of students appearing in this calendar
    @students = raw.map(&:student).uniq.sort_by(&:name)

    # wrap schedules into ScheduleGroups and group by date
    (@cal_begin..@cal_end).each do |date|
      grouped = ScheduleGroup.group( raw.select {|s| s.shift_on_date? date} )
      @schedules_by_date[date] = grouped unless grouped.nil?
    end
  end
end