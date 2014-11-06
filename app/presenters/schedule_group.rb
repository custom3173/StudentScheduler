# a schedule group represents a collection
#  of schedules treated as one element in the calendar
# ScheduleGroups have overlapping start and end times and
#  always belong to a single user. They are given a unique
#  id at creation for js and css styling
class ScheduleGroup

  # holds the processed shift data
  Shift = Struct.new( :start, :end, :type )
  
  attr_reader :schedules, :shifts, :id

  def initialize( schedules, id )
    @schedules = schedules
    @id = id

    schedules.each do |s1|
      schedules
    end
  end

end