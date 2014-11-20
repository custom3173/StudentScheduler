class Student < ActiveRecord::Base

  before_create :set_color_default

  COLORS = %w{ 
    #212121 #616161 #9e9e9e #e0e0e0
    #795548 #607D8B #1A237E #1B5E20
    #F44336 #E91E63 #9C27B0 #673AB7 
    #3F51B5 #2196F3 #03A9F4 #00BCD4
    #009688 #4CAF50 #8BC34A #CDDC39
    #FFEB3B #FFC107 #FF9800 #FF5722
  }

  DEFAULT_COLOR = '#F48FB1'

  has_many :schedules

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :nickname, uniqueness: true, length: { maximum: 10 },
              allow_nil: true, allow_blank: true
  validate  :approved_color

  def approved_color
    unless COLORS.include? color || color == DEFAULT_COLOR
      errors.add :color, 'PICK FROM THE LIST'
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
