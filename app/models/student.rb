class Student < ActiveRecord::Base
  include Shibbolite::User
  before_create :set_color_default

  # student calendar display color options
  COLORS = %w( 
    #212121 #616161 #9e9e9e #e0e0e0
    #795548 #607D8B #1A237E #1B5E20
    #F44336 #E91E63 #9C27B0 #673AB7
    #3F51B5 #2196F3 #03A9F4 #00BCD4
    #009688 #4CAF50 #8BC34A #CDDC39
    #FFEB3B #FFC107 #FF9800 #FF5722
  )

  DEFAULT_COLOR = '#F48FB1'

  has_many :schedules

  # todo: stop being lazy and rename
  #  this model 'User' already
  scope :admins, -> { where(group: 'admin') }

  validates :nickname, uniqueness: true, length: { maximum: 10 },
            allow_nil: true, allow_blank: true
  validate :approved_color

  def approved_color
    unless color.nil? || color == DEFAULT_COLOR || COLORS.include?(color)
      errors.add :color, 'PICK FROM THE LIST'
    end
  end

  # a nicely formatted name. Select the type with an optional code.
  # The name will default sensibly when the selected name is blank
  #  student.umbcusername #=> dbass
  #  student.displayName  #=> David Bassett
  #  student.nickname     #=> Alex
  #
  #  student.name :full     #=> David Bassett || umbcusername
  #  student.name :short    #=> Alex || David B || umbcusername
  def name(type=:short)
    if type == :short && !nickname.blank?
      nickname
    elsif type == :short && displayName
      first, last = displayName.split
      "#{first} #{last[0]}"
    elsif type == :full && displayName
      displayName
    else
      umbcusername
    end
  end

  private

  def set_color_default
    color ||= DEFAULT_COLOR
  end
end
