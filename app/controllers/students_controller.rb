class StudentsController < ApplicationController
  before_filter :set_student,
    only: [:show, :edit, :update, :update_display_options,
           :destroy, :purge_expired_schedules]

  before_action(except: [:show, :update_display_options, :purge_expired_schedules]) { |c| c.require_group :admin }

  # todo: replace with an AR scope
  def index
    @students = Student.where(group: 'student')
  end

  def administrators
    @students = Student.where(group: 'admin')
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

  # todo: goes in schedules controller
  def purge_expired_schedules
    _schedules = Schedule.where('student_id = ? AND end_date < ?', @student.id, Date.today)
    _schedules.each {|s| s.destroy}

    redirect_to @student, notice: 'Expired schedules have been deleted'
  end

  private

  def set_student
    @student = Student.find params[:id]
  end

  def load_student_schedules
    # todo: can probably delete this
    set_student unless @student

    @schedules = @student.schedules.group_by_status
    @schedules.each { |k, v| @schedules[k] = SchedulePresenter.wrap v }
  end

  # administrator permitted attributes
  def student_params
    params.require(:student).permit(:umbcusername, :group, :color, :nickname)
  end

  # student options
  def display_option_params
    params.require(:student).permit(:color, :nickname)
  end
end
