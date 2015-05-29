class SchedulesController < ApplicationController
  before_action :load_schedules

  before_action :require_login, only: [:index, :show, :calendar]
  before_action(only: [:new, :create, :edit, :update, :destroy]) do |c|
    c.require_group_or_id :admin, @student.id
  end

  # get|post /calendar
  def calendar
    # persist user's calendar options
    session[:calendar] ||= HashWithIndifferentAccess.new
    session[:calendar].merge!(params[:calendar] || {})

    @calendar = ScheduleCalendar.new(session[:calendar])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def index
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show ; end

  def edit ; end

  def new
    @schedule = @student.schedules.new

    # sensible defaults
    @schedule.start_date = Date.today
    @schedule.start_time = Time.new(2001,1,1,9) # 9:00 AM
    @schedule.end_time = Time.new(2001,1,1,12)  # 12:00 PM
  end

  def create
    @schedule = @student.schedules.new(schedule_params)

    if @schedule.save
      send_email new: SchedulePresenter.new( @schedule )
      redirect_to [@student, @schedule], notice: 'Schedule created!'
    else
      render action: "new"
    end
  end

  def update
    schedules = { new: @schedule, old: @schedule.dup }

    if @schedule.update_attributes(schedule_params)
      send_email schedules
      redirect_to [@student, @schedule], notice: 'Schedule updated!'
    else
      render action: "edit"
    end
  end

  def destroy
    schedules = { old: @schedule.dup }
    if @schedule.destroy
      send_email schedules
      message = { notice: 'Schedule deleted!' }
    else
      message = { notice: 'Schedule could not be deleted!' }
    end
    redirect_to @student, message
  end

  private

  def load_schedules
      @student = Student.find(params[:student_id]) if params[:student_id]
      if params[:id]
        schedule = Schedule.find(params[:id])
        @schedule = SchedulePresenter.new schedule
      end
      if params[:ids]
        schedules = Schedule.find(params[:ids])
        @schedules = SchedulePresenter.wrap schedules
      end
  end

  def schedule_params
    params.require(:schedule).permit(:description, :end_date, :end_time,
      :friday, :monday, :saturday, :start_date, :start_time, :group,
      :student_id, :sunday, :thursday, :tuesday, :wednesday)
  end

  def send_email(schedules)
    options = {}
    options[:new_sched] = schedules[:new]
    options[:old_sched] = schedules[:old]
    options[:student]   = @student
    options[:editor]    = current_user

    ServiceMailer.updated_schedule_email(options).deliver
  end
end
