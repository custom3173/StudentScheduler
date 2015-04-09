# handles sizing, positioning and coloring the schedules 
class Calendar
  defaults = {
    type:          'week'      # the display mode, may be day, week, or month
    pxPerMin:      0.8         # controls the height of sized elements
    gutter:        7           # width of the schedule separators (in px)
    schedClass:    '.schedule' #
    toggled:       '.off'      # schedules switched off by user
    labelClass:    '.name'     # css classnames
    detailedClass: '.detailed-schedules'
    compactClass:  '.compact-scedules'
  }
  dayDefaults = { # default overrides for type: 'day' calendars
    gutter: 28
  }
  monthDefaults = { # overrides for type: 'month'
  }

  # calendar should the parent container of all the display elements
  constructor: (opts={}) ->
    # defaults, be cautious about using invalid options
    if opts.type == 'day'
      $.extend @, defaults, dayDefaults, opts
    else if opts.type == 'month'
      $.extend @, defaults, monthDefaults, opts
    else
      $.extend @, defaults, opts

    @calendar = $('#calendar')

    # calendarDays are the schedule containers
    @calendarDays = @calendar.find('.cal-day')

    # various dimensions
    @labelHeight = @calendarDays.find(@labelClass).outerHeight(true)
    @timeHeight  = @calendarDays.find('.time').outerHeight(true)
    @dayWidth    = @calendarDays.innerWidth()

    # all schedules in the calendar
    @schedules = @calendarDays.find @schedClass

    # minutes before the first schedule begins
    @offset = 1440
    for schedule in $("#{@schedClass}:first-of-type")
      @offset = Math.min $(schedule).data('offset'), @offset

  draw: ->
    @colorize()
    if @type == 'week' || @type == 'day'
      @detailViewPosition()
      @detailViewLayers()
    @markDateAndTime()

  # set the colors on the schedule labels
  colorize: ->
    for student in $('#controls #students li')
      userId    = $(student).data 'user'
      color     = $(student).data 'color'
      contrast  = Colors.bgContrast color
      schedules = @schedules.filter("[data-user=#{userId}]")

      # month schedules are their own labels and have
      # other style changes
      if @type == 'month'
        labels = schedules
        borderReset = contrast
      else
        labels = schedules.find(@labelClass)
        borderReset = 'transparent'

      # turn off transitions before color change
      savedTransition = labels.css 'transition'
      labels.css transition: 'none'
      
      # set the students' custom colors
      studentColors = {
        color:       contrast
        background:  color
        borderColor: contrast
      }
      labels.css studentColors
      $(student).find('.name').css studentColors

      # avoid closure-in-loop issue
      # bind onhover border color change handler
      do (schedules, labels, color, borderReset) ->
        # set transitions back on
        setTimeout (-> labels.css transition: savedTransition ), 10
        schedules.hover ->
          $(this).css
            boxShadow: "0 0 5px #{color}"
            borderColor: color
        , ->
          $(this).css
            borderColor: borderReset
            boxShadow: ""

  # visually mark current day and time
  markDateAndTime: ->
    todayContainer = @calendarDays.filter('.td')
    if todayContainer.length
      # disable today button
      $('#today > a').button('disable')

      timelineOffset = @labelHeight + @timeHeight - @offset * @pxPerMin
      todayContainer
        .mark()
        .find(@detailedClass)
        .drawTimeline( offset: {top: timelineOffset} )

  # update the calendar view after elements are 
  #  changed/hidden in a way that doesn't require a
  #  complete redraw
  refreshDisplay: ->
    if @type == 'week' || @type == 'day'
      @detailViewLayers()
    else
      # todo: placeholder for month change refactors


  # Change the height and vertical positiong of each schedule
  detailViewPosition: ->
    # set the height of the vertical dividers
    for divider in $('.v-div')
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
  #  and tile them in columns to maximize the visibility of important
  #  elements
  detailViewLayers: ->
    # calculate the 'column' of each schedule first and a list of which
    #  schedules overlap each other. This will make calculating their
    #  relative positions possible
    for day in @calendarDays
      dailySchedules = $(day).find(@schedClass).not(@toggled)
      group = [] # overlapping schedules
      for schedule, i in dailySchedules

        sd = $(schedule).data()
        sd.left          = 0
        sd.index         = i
        sd.overlaps      = []
        sd.col           = null
        sd.width_divisor = 1
        label = $(schedule).children(@labelClass)

        # keep a list of overlapping schedules and filter out non-overlaps
        #  this keeps the runtime well less than O(n^2) usually
        # todo: this could use further refactoring
        for prevSched, j in group 
          prev_sd = $(prevSched).data()
          prev_label = $(prevSched).children(@labelClass)

          if prevSched?
            # schedules overlap
            if overlapHeight schedule, prevSched

              # sort out the overlap order
              top  = sd
              bottom = prev_sd
              [ top, bottom ] = [ bottom, top ] if sd.col?

              labels_overlap = overlapHeight( label, prev_label )
              bottom.width_divisor++ if labels_overlap
              top.overlaps.push {
                i: bottom.index
                include_label: labels_overlap
              }

            # schedules do not overlap
            else 
              group[j] = null
              unless sd.col?
                sd.col = j
                group[j] = schedule

          # fill column gaps
          else if !sd.col?
            sd.col = j
            group[j] = schedule

        # add schedule to end of array unless it was already inserted
        unless sd.col?
          sd.col = group.length
          group.push schedule

      # calculate the schedules' offsets
      max_column = group.length - 1
      for column in [0..max_column]
        for s1 in dailySchedules when $(s1).data().col == column
          sd1 = $(s1).data()

          for { i, include_label } in $(s1).data().overlaps
            s2 = $(dailySchedules)[i]
            sd2 = $(s2).data()
            if include_label
              sd1.left = sd2.left + sd2.width + @gutter
            else
              overlap_margin = widestLabel(s2, s1, false) + sd2.left
              sd1.left = overlap_margin if overlap_margin > sd1.left

          sd1.width = ((@dayWidth - sd1.left) - (max_column - column + 1) * @gutter) / sd1.width_divisor

          $(s1).zIndex sd1.col
          $(s1).css {
            left: sd1.left
            width: sd1.width
          }



# returns true when two elements overlap any Y axis
#  (height) point on the page
overlapHeight = (x1, x2) ->
  a = {top: $(x1).offset().top, bot: $(x1).offset().top + $(x1).height()}
  b = {top: $(x2).offset().top, bot: $(x2).offset().top + $(x2).height()}
  a.top <= b.bot and a.bot >= b.top

# returns the widest time label from schedule s1
#  that schedule s2 overlaps (in px)
widestLabel = (s1, s2, include_label) ->
  s1_items = $(s1).children()
  s1_items = s1_items.not('.name') unless include_label
  Math.max.apply( Math, s1_items
    .filter -> overlapHeight(this, s2)
    .map    -> $(this).outerWidth(true)
  )

window.buildCalendar = () ->
  # todo: this should be refactored into the Calendar class

  # jqui-ify calendar controls
  $('#date a').first()
    .button {
      text: false
      icons:
        primary: 'ui-icon-triangle-1-w'
    }
    .next().next().button {
      text: false
      icons:
        primary: 'ui-icon-triangle-1-e'
    }
  $('#today, #type').children('a').button()
  $('#students').hoverMenu()

  # todo: refactor into cal constructor
  type = $('#display').data('type')

  $('#type')
    .buttonset()
    .children("##{type}")
      .addClass('forced-active')

  # draw the calendar display
  calendar = new Calendar( type: type )
  calendar.draw()


  ### actions ###

  # make schedules selectable
  $('.schedule').click ->
    $('.selected').removeClass('selected')
    $(this).addClass('selected')

  # control visibility of schedules per student
  $('#students li')
    .click ->
      # style menu selection
      $(this).find('.icon').toggleClass 'hidden'
      $(this).find('.name').toggleClass 'greyed'

      # adjust schedule visibility
      studentSchedules = $(".schedule[data-user='#{$(this).data('user')}']")
      studentSchedules.toggleClass 'off'
      calendar.refreshDisplay()

############ doc ready ############
jQuery ->
  # condition prevents processing this
  # on other pages unnecessarily
  if $('#calendar').length
    buildCalendar()

    # refresh calendar every 10 minutes
    setInterval( (-> $.get( 'calendar' )), 600000)