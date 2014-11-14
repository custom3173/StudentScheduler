# some size/proportion controls
#  schedule element heights in pixels
label_hgt     = 21
px_per_minute = 48 / 60
tag_hgt       = 17
time_width    = 40 # this is a guess
gutter_width  = 7 #todo: JS lookup constant conventions

# sets the height of the schedule div and the
#  decorative border that connects the shift times
resizeSchedule = ->
  schedule = $(this)
  sData = schedule.data()

  cal_offset = $('#schedule-data').data('offset')
  start_time = rubyTimeToMinutes sData.start_time

  left_offset = sData.overlapping * time_width
  schedule_width = schedule.width() - (left_offset + gutter_width * sData.overlapped_by)

  schedule.css {
    'position': 'absolute',
    'left':   "#{left_offset}px",
    'width':  "#{schedule_width}px"
  }

  top_offset = (start_time - cal_offset) * px_per_minute

  schedule.children('.b-line').each ->
    minutes = $(this).data 'length'
    height  = Math.floor(minutes * px_per_minute - tag_hgt)
    $(this).height height

  schedule_height = schedule.children()
    .map -> $(this).height()
    .toArray()
    .reduce (acc, e) -> acc + e

  schedule.css {
    'top':    "#{top_offset}px",
    'height': "#{schedule_height}px"
  }

rubyTimeToMinutes = (datetime_str) ->
  tmp = new Date(datetime_str)
  tmp.getUTCHours()*60 + tmp.getMinutes()

jQuery -> 
  calendar   = $('#schedule-data').data('schedules') # todo, remove

  $('.schedule').each resizeSchedule