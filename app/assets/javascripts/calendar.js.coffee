# some size/proportion controls
#  schedule element heights in pixels
hour_hgt      = 48
label_hgt     = 21
time_tags_hgt = 40
bline_offset  = label_hgt + time_tags_hgt

# sets the height of the schedule div and the
#  decorative border that connects the shift times
resizeSchedule = (s) ->
  schedule_hgt = (s.minutes * hour_hgt / 60) + label_hgt
  bline_hgt    = schedule_hgt - bline_offset

  s_obj = getSchedule s
  s_obj.css('height', "#{schedule_hgt}px")
  s_obj.children('.b-line').css('height', "#{bline_hgt}px")

# changes the offsets of the schedules so they are
#  positioned relative to each other
offsetSchedule = (s, cal_offset) ->
  schedule_offset = (s.start_time - cal_offset) * hour_hgt / 60
  s_obj = getSchedule s
  s_obj.css {
    'top': "#{schedule_offset}px",
    'position': 'absolute'
  }

rubyTimeToMinutes = (datetime_str) ->
  tmp = new Date(datetime_str)
  tmp.getUTCHours()*60 + tmp.getMinutes()

getSchedule = (s) ->
  $("#sched-#{s.cid}")

jQuery -> 
  calendar   = $('#schedule-data').data('schedules')
  cal_offset = $('#schedule-data').data('offset')

  for date, schedules of calendar
    for schedule in schedules
      schedule.start_time = rubyTimeToMinutes(schedule.start_time)
      schedule.end_time   = rubyTimeToMinutes(schedule.end_time)
      schedule.minutes    = schedule.end_time - schedule.start_time

      resizeSchedule( schedule )
      offsetSchedule( schedule, cal_offset )