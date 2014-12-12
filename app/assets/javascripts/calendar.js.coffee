# some size/proportion controls
#  schedule element heights in pixels
label_hgt     = 21
px_per_minute = 48 / 60
tag_hgt       = 20
time_width    = 50 # this is a guess
gutter_width  = 7 #todo: JS lookup constant conventions
base_width    = 133
buffer = gutter_width
min_offset = gutter_width

# set the colors on the user's schedule labels
colorize = (schedule) ->
  textColor = Colors.bgContrast schedule.data().color
  schedule.find('.name').css {
    background:  schedule.data().color
    borderColor: textColor
    color:       textColor
  }

# sets the height of the schedule div and the
#  decorative border that connects the shift times
# TODO: refactor this monster
position = (schedule) ->
  sData = schedule.data()

  cal_offset = $('#schedule-data').data('offset') #todo
  start_time = rubyTimeToMinutes sData.start_time

  # set schedule width
  schedule.css {
    position: 'absolute'
  }

  top_offset = (start_time - cal_offset) * px_per_minute

  # set bline height 
  schedule.children('.b-line').each ->
    minutes = $(this).data 'length'
    height  = Math.round(minutes * px_per_minute - tag_hgt)
    $(this).height height

  schedule_height = schedule.children()
    .map -> $(this).height()
    .toArray()
    .reduce (acc, e) -> acc + e

  schedule.css {
    top:    top_offset
    height: schedule_height
  }

# temp until i know what im doing
resize = (schedules) ->
  group = [] # overlapping schedules

  # calculate the 'column' of each schedule first and a list of which
  #  schedules overlap each other. This will make calculating their
  #  relative positions possible
  $(schedules).each (i) ->
    schedule = $(this) # current schedule
    col_set = false    # don't increment column after setting

    prev_prev_col = -1
    schedule.data().index    = i
    schedule.data().col      = 0
    schedule.data().left     = 0
    schedule.data().gutter   = 0
    schedule.data().overlaps = []

    # keep a list of overlapping schedules and filter out non-overlaps
    #  this keeps the runtime well less than O(n^2) usually
    group = group.filter (prevSched) ->

      # fill first gap found unless column is already set
      if !col_set && prevSched.data().col > prev_prev_col + 1
        schedule.data().col = prev_prev_col + 1
        col_set = true
      
      prev_prev_col = prevSched.data().col

      # schedules overlap; increment col and return true for filter
      if overlapHeight schedule, prevSched
        if col_set
          prevSched.data().overlaps.push schedule.data().index
        else
          schedule.data().overlaps.push prevSched.data().index
          schedule.data().col++
        true

      # the schedules don't overlap, new schedule replaces
      #  the previous and filter out the schedule
      else 
        unless col_set
          schedule.data().col = prevSched.data().col
          col_set = true
        false

    group.push schedule

    # calculate the width of the gutters
    for sched in group
      sched.data().gutter = Math.max(sched.data().gutter, (group.length - 1) - sched.data().col)

  max_col = Math.max.apply(Math, $(schedules).map( -> $(this).data().col))

  # calculate the schedules' offsets
  for column in [0..max_col]
    for s1 in schedules when $(s1).data().col == column
      sd1 = $(s1).data()

      for i in $(s1).data().overlaps
        s2 = $(schedules)[i]
        sd2 = $(s2).data()

        sd1.left = Math.max widestLabel(s2, s1) + sd2.left + buffer, sd1.left

        # calculate gutters (i guess)
        # calculate width

      #$(s1).find('.name').text(sd1.col)
      $(s1).css {
        left: sd1.left
        width: base_width - sd1.left - sd1.gutter * gutter_width
      }

# returns true when two elements overlap any Y axis
#  (height) point on the page
overlapHeight = (x1, x2) ->
  a = {
    top: $(x1).offset().top
    bot: $(x1).offset().top + $(x1).height()
  }
  b = {
    top: $(x2).offset().top
    bot: $(x2).offset().top + $(x2).height()
  }
  a.top <= b.bot and a.bot >= b.top

# returns the widest time label from schedule s1
#  that schedule s2 overlaps (in px)
widestLabel = (s1, s2) ->
  Math.max.apply(Math, $(s1).children().not('.name').filter( -> overlapHeight(this, s2)).map( -> $(this).outerWidth(true)))

rubyTimeToMinutes = (datetime_str) ->
  tmp = new Date(datetime_str)
  tmp.getUTCHours()*60 + tmp.getMinutes()

jQuery -> 
  calendar   = $('#schedule-data').data('schedules') # todo, remove
  cal_offset = $('#schedule-data').data('offset') # todo, refactor

  # colorize and add handlers to schedules
  $('.schedule').each ->
    schedule = $(this)
    colorize schedule
    position schedule

    # bring clicked schedules to the front
    schedule.click ->
      $('.selected').removeClass('selected')
      $(this).addClass('selected')

  # resize and place schedules relative to each other
  #  (separated by day)
  $('.cal-day').each ->
    schedules = $(this).find('.schedule')
    resize schedules

  # place a marker above today's schedules and mark the time
  $('#td').mark()

  timelineOffset = label_hgt + tag_hgt - cal_offset * px_per_minute
  $('#td').find('.hourly-view').drawTimeline( offset: {top: timelineOffset})