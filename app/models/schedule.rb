class Schedule < ActiveRecord::Base
  belongs_to :student

  # important! maintain order
  enum group: [:regular, :temporary, :absent]

  validates_presence_of :start_date, :end_date, :start_time, :end_time, :group
  validates :description, :length => {maximum: 500}
  validate :end_date_after_start_date, :end_time_after_start_time,
           :at_least_one_day_selected

  # validate end_date > start_date
  def end_date_after_start_date
    if start_date && end_date && end_date < start_date
      errors.add :end_date, "must be after the start date"
      errors.add :start_date, "must be before the end date"
    end
  end

  # validate end_time > start_time
  def end_time_after_start_time
    if start_time && end_time && end_time < start_time
      errors.add :end_time, "must be after the start of shift"
      errors.add :start_time, "must be before the end of shift"
    end
  end

  # validate at least one date M-Su is selected
  def at_least_one_day_selected
    unless monday or tuesday or wednesday or thursday or friday or saturday or sunday
      errors.add :on_days, "At least one day must be selected"
    end
  end

  # scope for active schedules in a date range
  #  ordered by start_time
  def self.in_date_range (d_start, d_end=nil)
    d_end ||= d_start
    where("start_date <= ? AND end_date >= ?", d_end, d_start)
      .where(active: true)
      .order(:start_time)
  end

  # virtual attribute for cleaning up the days booleans
  # todo goes in the presenter
  def days_of_week

    # create an array for processing
    days_array = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    int_array = Array.new
    for day in days_array
        day ? int_array.push(1) : int_array.push(0)
    end

    # process with little recursive function
    r(int_array, 0)
    # fix first value, see note below
    int_array[0] == -1 ? int_array[0] = 1 : nil

    # final passes, change values into useable string
    int_array[0] == 1 ? int_array[0] = 'Su' : nil
    int_array[1] == 1 ? int_array[1] = 'M' : nil
    int_array[2] == 1 ? int_array[2] = 'Tu' : nil
    int_array[3] == 1 ? int_array[3] = 'W' : nil
    int_array[4] == 1 ? int_array[4] = 'Th' : nil
    int_array[5] == 1 ? int_array[5] = 'F' : nil
    int_array[6] == 1 ? int_array[6] = 'Sa' : nil

    int_array.delete(0)
    int_array.map{ |x| x == -1 ? '-' : x}.uniq.join

  end

  private
  
  # this little recursive function processes an array of "day booleans"
  # and determines which days should be replaced by a hyphen. helps the
  # days_of_week virtual attribute. 
  #
  # in : [0,1,1,1,0,1,0]
  # out: [0,1,-1,1,0,1,0]
  # Note: the fist value, x[0], will need to be set to positive after processing
  #        in some cases. i.e. [1,1,1,0,0,0,0] -> [-1,-1,1,0,0,0,0]
  def r (x, i)
      unless x[i] == nil
        tmp = r(x, i+1)
      else return 0
      end
      
      if tmp != 0
          if tmp == -1 and x[i] == 0
              x[i+1] = 1
              return x[i]
          else return x[i] = x[i] * -1
          end
      else return x[i]
      end
  end
end
