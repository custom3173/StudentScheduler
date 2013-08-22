class ApplicationController < ActionController::Base
  protect_from_forgery

  def unload_session
    session[:user_id] = nil
    session[:username] = nil
    session[:campus_id] = nil
    session[:admin] = false
    session[:registered] = false

    redirect_to 'https://webauth.umbc.edu/umbcLogin?action=logout'
  end

  protected

  def load_user_into_session
    unless session[:username]

      # if the user is registered and has his data in the system
      if student = Student.find_by_campus_id(request.env["umbccampusid"])
        session[:user_id] = student.id
        session[:username] = student.username
        session[:campus_id] = student.campus_id
        session[:admin] = student.admin
        session[:registered] = true

      # the user has been registered by an admin but has never logged in before
      elsif student = Student.find_by_username(request.env["umbcusername"])
        student.campus_id = request.env["umbccampusid"]
        student.department = request.env["umbcDepartment"]
        student.lims = request.env["umbclims"]
        student.first_name = request.env["displayName"].split(' ').first
        student.last_name = request.env["displayName"].split(' ').last
        student.email = request.env["mail"]

        student.save  # save the student's details from shibboleth

        session[:user_id] = student.id
        session[:username] = student.username
        session[:campus_id] = student.campus_id
        session[:admin] = student.admin
        session[:registered] = true

      # the user is just a visitor
      else
        session[:user_id] = nil
        session[:username] = request.env["umbcusername"]
        session[:campus_id] = request.env["umbccampusid"]
        session[:admin] = false
        session[:registered] = false
      end
    end
    return true
  end

  # a filter to verify that an admin account is present before allowing access
  def admin_verification
    unless session[:admin]
      redirect_to '/studentscheduler/403.html'
      return false
    end
  end

  # a filter to verify that that a non-admin account can only access their own data
  def user_verification
    id = params[:student_id] || params[:id] # :student_id is correct for nested schedule routes
    unless session[:admin] or session[:user_id] == id.to_i
      redirect_to '/studentscheduler/403.html'
      return false
    end
  end
end
