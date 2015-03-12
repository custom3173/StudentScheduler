# David Bassett - 2014

# JQuery plugins

# create a floating marker to highlight important or
#  selected elements without disturbing the document flow
$.fn.mark = (opts) ->
  opts = $.extend true, {}, $.fn.mark.options, opts

  this.each ->
    elem = $(this)

    marker = $("<span/>", {
      class: [opts.markerClass, 'sc-mark'].join ' '
    }).prependTo elem

    marker.css { position: 'absolute' }

    marker.zIndex(999)
    marker.position {
      my: 'bottom-30%'
      at: 'top'
      of: elem
      collision: 'none'
    }
  return this

$.fn.mark.options = {
  type:        'top' # not yet used
  markerClass: 'mark'
  markerHeight: 7
  offset: {
    top:    0
    left:   0
  }
}

# remove any marker elements
$.fn.unmark = -> 
  $(this).children('.sc-mark').remove()

# Draws a horizontal rule in the provided element
#  marking the current time for today
$.fn.drawTimeline = (opts) ->
  opts = $.extend true, {}, $.fn.drawTimeline.options, opts
  elem = $(this)
  d    = new Date
  timeOffset  = (d.getHours()*60 + d.getMinutes()) * opts.pxPerMin

  top  = opts.offset.top + timeOffset
  left = opts.offset.left

  newElem = $("<hr/>", {
    class: opts.class
  }).prependTo elem

  newElem.zIndex(999)

  newElem.css {
    position: 'absolute'
    top:      0
    left:     Math.round(left)
  }

  # todo: refactor this
  setTimeout( ->
   newElem.css {
    top: Math.round(top)
  }, 1)

$.fn.drawTimeline.options = {
  class:    'timeline'
  pxPerMin: 0.8
  offset: {
    top:    0
    left:   0
  }
}

# take a button and list and create a simple hover menu
$.fn.hoverMenu = ->
  menu = $(this)

  menu.find('#menu-text')
    .button {
      icons:
        secondary: "ui-icon-triangle-1-s"
    }

  # hide and show menu
  menu.hover ->
    $(this).find('ul')
      .stop(true)
      .toggle {
        effect: 'blind'
        duration: 200
      }

  menu.find('ul')
    .menu()
    .position
      my: 'left top'
      at: 'left bottom'
      of: menu.find('#menu-text')
    .hide()
  return this

# hacky method for calculating the width of an elements
#  rendered text
# Note: It looks like it is at least a few pixels off
$.fn.textWidth = ->
  html_org = $(this).html()
  html_calc = '<span>' + html_org + '</span>'
  $(this).html(html_calc)
  width = $(this).find('span:first').width()
  $(this).html(html_org)
  width