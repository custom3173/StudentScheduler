class StudentsController < ApplicationController


  before_filter :load_user_into_session
  before_filter :admin_verification, :except => [:calendar, :show, :purge_expired_schedules]
  before_filter :user_verification, :only => [:show, :purge_expired_schedules]

  # GET /calendar
  # POST /calendar
  def calendar
    # move Sunday to the end so it conforms with ISO 8601
    #  this allows it to work with Date.beginning_of_week
    #  and .end_of_week. Also it just looks nicer
    @days_of_week = Array.new(Date::DAYNAMES)[1..-1] << Date::DAYNAMES.first

    # pull the date param (user input) and parse a valid date
    valid_date?(params[:date]) ? @date = Date.parse(params[:date]) : @date = Date.today

    @students = Student.all # get their names

    # narrow down to only currently valid schedules by
    # iterating from the beginning of the week (the current or previous monday)
    @schedules_by_day = Array.new        # store arrays of schedules
    _date = @date.beginning_of_week - 1  # date for iteration
    until _date == @date.end_of_week do
      _date += 1
      # gets each schedule that is valid for the date AND has the appropriate day boolean set
      @schedules_by_day << Schedule.where('start_date <= :current_date AND end_date >= :current_date AND ' + _date.strftime('%A').downcase + ' = 1',
                                          {:current_date => _date, })
    end

    render
  end

  # GET /students
  # GET /students.json
  def index
    @students = Student.where("admin = false")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @students }
    end
  end


  # get /administrators
  # this is the admins-only index page
  def administrators
    @students = Student.where("admin = true")
  end


  # GET /students/1
  # GET /students/1.json
  def show
    @student = Student.find(params[:id])

    # todo: need scopes and to be a single db call
    _d = Date.today
    @schedules = {}
    @schedules['Active']   = Schedule.where('student_id = ? AND start_date <= ? AND end_date >= ?', @student.id, _d, _d)
    @schedules['Upcoming'] = Schedule.where('student_id = ? AND start_date > ?', @student.id, _d)
    @schedules['Expired']  = Schedule.where('student_id = ? AND end_date < ?', @student.id, _d)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/new
  # GET /students/new.json
  def new
    @student = Student.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/1/edit
  def edit
    @student = Student.find(params[:id])
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'User was successfully created.' }
        format.json { render json: @student, status: :created, location: @student }
      else
        format.html { render action: "new" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /students/1
  # PUT /students/1.json
  def update
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(student_params)
        format.html { redirect_to @student, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student = Student.find(params[:id])
    @student.schedules.each {|s| s.destroy}
    @student.destroy

    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  # get /students/1/purge
  def purge_expired_schedules
    @student = Student.find(params[:id])

    _schedules = Schedule.where('student_id = ? AND end_date < ?', @student.id, Date.today)
    _schedules.each {|s| s.destroy}

    redirect_to @student
  end

  private

  def student_params
    params.require(:student).permit(:first_name, :last_name, :username, :email, :department, :lims, :admin)
  end

  # takes a questionable date string and attempts to parse it
  #  could use some improvement
  def valid_date? (date_string)
    begin
      Date.parse(date_string)
      true
    rescue
      false
    end
  end
end

