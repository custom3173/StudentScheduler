# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Studentscheduler::Application.initialize!

# some date and time formats
Time::DATE_FORMATS[:short] = "%-I:%M%P"