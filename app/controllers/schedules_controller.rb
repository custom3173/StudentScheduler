class SchedulesController < ApplicationController

  before_filter :load_student
  before_filter :user_verification

  # get|post /calendar
  def calendar

    @calendar = CalendarSchedule.new
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
    @schedule = Schedule.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.json
  def new
    @schedule = @student.schedules.new

    # sensible defaults
    @schedule.start_date = Date.today
    @schedule.start_time = Time.new(2001,1,1,9) # 9:00 AM
    @schedule.end_time = Time.new(2001,1,1,12)  # 12:00 PM

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = @student.schedules.find(params[:id])
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = @student.schedules.new(schedule_params)

    respond_to do |format|
      if @schedule.save

        # send notification email
        editor = Student.find_by_username(session[:username])
        Student.where("admin = true").push(@student).each do |recipient|
          ServiceMailer.created_schedule_email(recipient, @student, editor, @schedule).deliver unless recipient.email.nil?
        end

        format.html { redirect_to [@student, @schedule], notice: 'Schedule was successfully created.' }
        format.json { render json: @schedule, status: :created, location: @schedule }
      else
        format.html { render action: "new" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.json
  def update
    @schedule = @student.schedules.find(params[:id])
    old_schedule = @schedule.dup # save the old schedule before it updates to send it to the mailer

    respond_to do |format|
      if @schedule.update_attributes(schedule_params)

        # send notification email
        editor = Student.find_by_username(session[:username])
        Student.where("admin = true").push(@student).each do |recipient|
          ServiceMailer.updated_schedule_email(recipient, @student, editor, old_schedule, @schedule).deliver unless recipient.email.nil?
        end

        format.html { redirect_to [@student, @schedule], notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule = @student.schedules.find(params[:id])
    old_schedule = @schedule.dup # save the old schedule before it is deleted to send it to the mailer
    @schedule.destroy

    # send notification email
    editor = Student.find_by_username(session[:username])
    Student.where("admin = true").push(@student).each do |recipient|
      ServiceMailer.deleted_schedule_email(recipient, @student, editor, old_schedule).deliver unless recipient.email.nil?
    end

    respond_to do |format|
      format.html { redirect_to @student }
      format.json { head :no_content }
    end
  end

  # post /students/1/mark_tomorrow_absent
  def mark_tomorrow_absent_form
    @student = Student.find(params[:id])
    @schedule = @student.schedules.new
  end

  # post /students/1/mark_tomorrow_absent
  def mark_tomorrow_absent
    @student = Student.find(params[:id])
    @schedule = @student.schedules.new(schedule_params)

    # set the rest of the schedule accordingly
    @schedule.start_date = Date.tomorrow
    @schedule.end_date = Date.tomorrow
    @schedule.start_time = DateTime.parse("8:00 am")
    @schedule.end_time = DateTime.parse("8:00 pm")
    @schedule.monday = true if Date.tomorrow.monday?
    @schedule.tuesday = true if Date.tomorrow.tuesday?
    @schedule.wednesday = true if Date.tomorrow.wednesday?
    @schedule.thursday = true if Date.tomorrow.thursday?
    @schedule.friday = true if Date.tomorrow.friday?
    @schedule.saturday = true if Date.tomorrow.saturday?
    @schedule.sunday = true if Date.tomorrow.sunday?
    @schedule.absent = true

    if @schedule.save

      # send notification email
      editor = Student.find_by_username(session[:username])
      Student.where("admin = true").push(@student).each do |recipient|
        ServiceMailer.called_out_tomorrow_email(recipient, @student, editor, @schedule).deliver unless recipient.email.nil?
      end

      redirect_to @student, notice: 'Your schedule has been updated.'
    else
      render action: 'mark_tomorrow_absent_form'
    end

  end

  private

  def schedule_params
    params.require(:schedule).permit(:description, :end_date, :end_time,
      :friday, :monday, :saturday, :start_date, :start_time, :group,
      :student_id, :sunday, :thursday, :tuesday, :wednesday)
  end

  def load_student
    if params[:student_id]
      @student = Student.find_by_id(params[:student_id])
    end
  end

end
