# handles sizing, positioning and coloring the schedules 
class Calendar
  defaults = {
    type:       'week'      # the display mode, may be day, week, or month
    pxPerMin:   0.8         # controls the height of sized elements
    gutter:     7           # width of the schedule seperators (in px)
    schedClass: '.schedule' #
    labelClass: '.name'     # css classnames
    timeClass:  '.time'     #
    vDivClass:  '.v-div'    # vertical divider
  }

  # calendarDays are the schedule containers (jQ obj expected)
  constructor: (@calendarDays, opts={}) ->
    # defaults, be cautious about using invalid options
    $.extend @, defaults, opts

    # various dimensions
    @labelHeight = @calendarDays.find(@labelClass).outerHeight(true)
    @timeHeight  = @calendarDays.find(@timeClass).outerHeight(true)
    @dayWidth    = @calendarDays.innerWidth()

    # all schedules in the calendar
    @schedules = @calendarDays.find @schedClass

    # minutes before the first schedule begins
    @offset = 1440
    for schedule in $("#{@schedClass}:first-of-type")
      @offset = Math.min $(schedule).data('offset'), @offset

  draw: ->
    @colorize()
    @position()
    @resize()

  # set the colors on the schedule labels
  colorize: ->
    contrast = {}
    # don't compute contrast colors more than once
    for schedule in @schedules when not contrast[ $(schedule).data('color') ]?
      color = $(schedule).data('color')
      contrast[ color ] = Colors.bgContrast color

      $(@schedules).filter("[data-color=#{color}]").find(@labelClass).css {
        background:  color
        borderColor: contrast[ color ]
        color:       contrast[ color ]
      }

  # Change the height of each schedule and position on the calendar
  position: ->
    # set the height of the vertical dividers
    for divider in $(@vDivClass)
      duration = $(divider).data 'length'
      $(divider).height Math.round( duration*@pxPerMin - @timeHeight )

    # set the overall schedule height
    for schedule in @schedules
      scheduleHeight = 0
      scheduleHeight += $(child).height() for child in $(schedule).children()
      $(schedule).css {
        position: 'absolute'
        height:   scheduleHeight
        top:      ($(schedule).data('offset') - @offset) * @pxPerMin
      }

  # set the width and offset of the schedules relative to each other
  resize: ->
    # calculate the 'column' of each schedule first and a list of which
    #  schedules overlap each other. This will make calculating their
    #  relative positions possible
    for day in @calendarDays
      dailySchedules = $(day).find @schedClass
      group = [] # overlapping schedules
      console.log "DAY"
      for schedule, i in dailySchedules
        console.log "-Schedule#{i}"
        col_set = false    # don't increment column after setting

        prev_prev_col = -1
        sd = $(schedule).data()
        sd.index    = i
        sd.col      = 0
        sd.left     = 0
        sd.gutter   = 0
        sd.overlaps = []

        # keep a list of overlapping schedules and filter out non-overlaps
        #  this keeps the runtime well less than O(n^2) usually
        group = group.filter (prevSched) ->
          console.log "--group"
          prev_sd = $(prevSched).data()

          # fill first gap found unless column is already set
          if !col_set && prev_sd.col > prev_prev_col + 1
            sd.col = prev_prev_col + 1
            console.log "---Schedule#{i} found gap in col #{sd.col}"
            col_set = true
          
          prev_prev_col = prev_sd.col

          # schedules overlap; increment col and return true for filter
          if overlapHeight schedule, prevSched
            if col_set
              prev_sd.overlaps.push sd.index
              console.log "---Schedule#{i} overlapped by #{prev_sd.index}"
            else
              sd.overlaps.push prev_sd.index
              console.log "---Schedule#{i} overlaps #{prev_sd.index}"
              sd.col++
            true

          # the schedules don't overlap, new schedule replaces
          #  the previous and filter out the schedule
          else 
            console.log "---Schedule#{i} doesn't overlap #{prev_sd.index}"
            unless col_set
              console.log "----and it replaces #{prev_sd.index}"
              sd.col = prev_sd.col # HERE <<< pushing a schedule on the end doesn't fill the gap
              col_set = true
            false

        group.push schedule

        # calculate the width of the gutters
        # todo: gutters and max_col can be done faster
        for sched in group
          sd = $(sched).data()
          sd.gutter = Math.max(sd.gutter, (group.length) - sd.col)

      max_col = 0
      $(dailySchedules).each ->
        col = $(this).data('col')
        max_col = col if col > max_col

      # calculate the schedules' offsets
      for column in [0..max_col]
        for s1 in dailySchedules when $(s1).data().col == column
          sd1 = $(s1).data()

          for i in $(s1).data().overlaps
            s2 = $(dailySchedules)[i]
            sd2 = $(s2).data()

            sd1.left = Math.max widestLabel(s2, s1) + sd2.left + 7, sd1.left

          $(s1).zIndex sd1.col
          $(s1).css {
            left: sd1.left
            width: @dayWidth - sd1.left - sd1.gutter * 7
          }




# some size/proportion controls
#  schedule element heights in pixels
label_hgt     = 21
px_per_minute = 48 / 60


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

############ doc ready ############
jQuery ->
  tag_hgt       = $('.time').first().height()

  cal_offset = $('#calendar').data('offset') # todo, refactor

  # colorize and add handlers to schedules
  $('.schedule').each ->
    schedule = $(this)
    #colorize schedule
    #position schedule

    # bring clicked schedules to the front
    schedule.click ->
      $('.selected').removeClass('selected')
      $(this).addClass('selected')


  # place a marker above today's schedules and mark the time
  $('#td').mark()

  timelineOffset = label_hgt + tag_hgt - cal_offset * px_per_minute
  $('#td').find('.hourly-view').drawTimeline( offset: {top: timelineOffset})

  calendar = new Calendar($('.cal-day'))
  calendar.draw()