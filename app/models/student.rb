class Student < ActiveRecord::Base

  before_create :set_color_default

  COLORS = %w(#ccc #ddd)
  DEFAULT_COLOR = '#ddd' # make me pink

  has_many :schedules

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :nickname, uniqueness: true
  validate  :approved_color

  def approved_color
    unless COLORS.include? color
      errors.add :color 'PICK FROM THE LIST'
    end
  end

  # picks a user's displayname
  def name
    nickname || short_name
  end

  # shortened version of the name
  #  Jeff Ross becomes Jeff R
  def short_name
      sn = "#{first_name} #{last_name[0,1]}"
      sn.blank? ? username : sn
  end

  def fullname
    fn = "#{first_name} #{last_name}"
    fn.blank? ? nil : fn
  end


  private

  def set_color_default
    color ||= DEFAULT_COLOR
  end
end
