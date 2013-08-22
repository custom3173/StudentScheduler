class Student < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :username, :email, :department, :lims, :admin
  # admin and campus_id protected by default from mass assignment

  has_many :schedules

  validates_uniqueness_of :username, :case_sensitive => false, :message => '- This user already exists'

  # shortened version of the name
  #  Jeff Ross becomes Jeff R
  def short_name
    if last_name
      "#{first_name} #{last_name[0,1]}"
    else
      username
    end
  end

  # combined first and last name
  def fullname
    "#{first_name} #{last_name}"
  end

end
