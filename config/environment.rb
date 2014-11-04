# Load the rails application
require File.expand_path('../application', __FILE__)

# some date and time formats
Time::DATE_FORMATS[:short] = "%-I:%M%P"
Time::DATE_FORMATS[:hour] = "%-I%P"
Date::DATE_FORMATS[:cal] = "%a %-m/%-d"

# Initialize the rails application
Studentscheduler::Application.initialize!