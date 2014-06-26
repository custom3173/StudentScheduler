module Controllers
  shared_context 'auth_helpers' do

    # lets current_user return the specified attributes for simulating
    # authentication methods for shibbolite
    def log_in_as (options = {umbcusername: 'current_user'})
      @c_user = FactoryGirl.build(:user, options)
      User.stub(:find_user) { @c_user }
      session[:umbcusername] = options[:umbcusername]
    end

    # sets a specific attribute in
    # request.env for the current user
    def set_env_attribute(attr, value)
      request.env[attr.to_s] = value
    end

    def logout
      session.delete(:umbcusername)
      @c_user = nil
      @current_user = nil
    end

  end
end