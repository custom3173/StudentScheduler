module SchedulesHelper

  # wrapper for content tag the clean up data 
  #  passing elements
  def data_tag (id, data)
    content_tag :div, nil, id: id, data: data
  end
end
