class ApplicationController < ActionController::Base
  include Shibbolite::Filters
  protect_from_forgery
end
