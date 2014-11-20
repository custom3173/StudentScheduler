class StudentsController < ApplicationController

  before_filter :load_student,
    only: [:show, :edit, :update, :update_display_options,
           :destroy, :purge_expired_schedules]

  before_filter :load_user_into_session

  before_filter :admin_verification,
    :except => [:calendar, :show, :purge_expired_schedules]

  before_filter :user_verification,
    :only => [:show, :purge_expired_schedules]

  def index
    @students = Student.where("admin = false")
  end

  def administrators
    @students = Student.where("admin = true")
  end

  def show
    load_student_schedules
  end

  def new
    @student = Student.new
  end

  def edit ; end

  def create
    @student = Student.new(student_params)
    @student.color ||= Student::DEFAULT_COLOR

    if @student.save
      redirect_to @student, notice: 'User was successfully created'
    else
      render action: "new"
    end
  end

  def update
    if @student.update_attributes(student_params)
      redirect_to @student, notice: 'User was successfully updated'
    else
      render action: "edit"
    end
  end

  def update_display_options
    if @student.update_attributes(display_option_params)
      redirect_to @student, notice: 'Calendar options were successfully updated'
    else
      load_student_schedules
      render action: "show"
    end
  end

  def destroy
    @student.schedules.each {|s| s.destroy}
    @student.destroy

    redirect_to students_url
  end

  def purge_expired_schedules
    _schedules = Schedule.where('student_id = ? AND end_date < ?', @student.id, Date.today)
    _schedules.each {|s| s.destroy}

    redirect_to @student, notice: 'Expired schedules have been deleted'
  end

  private

  def load_student
    @student = Student.find(params[:id])
  end

  def load_student_schedules
    load_student unless @student

    # todo: need scopes and to be a single db call
    _d = Date.today
    @schedules = {}
    @schedules['Active']   = Schedule.where('student_id = ? AND start_date <= ? AND end_date >= ?', @student.id, _d, _d)
    @schedules['Upcoming'] = Schedule.where('student_id = ? AND start_date > ?', @student.id, _d)
    @schedules['Expired']  = Schedule.where('student_id = ? AND end_date < ?', @student.id, _d)
  end

  # administrator permitted attributes
  def student_params
    params.require(:student).permit(
      :first_name, :last_name, :username,   :email,
      :department, :lims,      :admin,      :color,
      :nickname
    )
  end

  # student options
  def display_option_params
    params.require(:student).permit(:color, :nickname)
  end
end