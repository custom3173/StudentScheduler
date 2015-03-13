# These configuration options must be set before Shibbolite
# can be loaded. Mandatory settings are :attributes, :user_class,
# and :primary_user_id. Depending on your environment you may
# also have to change :handler_url, :session_initiator, or :logout_initiator
# if they are different from the default values. Check with your SP's
# shibboleth.xml configuration for the correct settings.
Shibbolite.config do |c|

  # any shibboleth attributes available in your environment that you want
  # passed to your application.
  c.attributes = [:umbcusername, :displayName, :umbcDepartment, :mail]

  # SP attribute used as a unique username
  # typically this should be the same attribute that
  # your SP uses to set the REMOTE_USER environment variable
  # Use the getter alias Shibbolite.pid of you want to be concise
  c.primary_user_id = :umbcusername

  # The defaults for these options will work for most installations
  # all options are listed with their default values, only uncomment
  # if you need to change them

  # friendly display name for views
  # concise alias Shibbolite.pid_display is available too
  #c.primary_user_id_display = 'Username'

  # name of your application's User model
  c.user_class = 'Student'

  # used with the generated migration.
  # Only override if your table doesn't follow
  # normal pluralization or name conventions
  #c.user_table_name = c.user_class.pluralize

  # NativeSP base location
  # used to construct urls to interact with SP
  #c.handler_url = '/Shibboleth.sso'

  # NativeSP handler location for starting sessions
  #c.session_initiator = '/Login'

  # NativeSP handler location for logging out
  #c.logout_initiator = '/Logout'

  # the types of groups to assign users
  c.groups = [:student, :admin]

  # setting to true will skip including validations
  # from the Shibbolite::User class
  #c.skip_validations = false
end