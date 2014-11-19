# JQuery plugins

# create a floating marker to highlight important or
#  selected elements without disturbing the document flow
$.fn.mark = (opts) ->
  opts = $.extend true, {}, $.fn.mark.options, opts

  this.each ->
    elem = $(this)

    # get these now before the marker is placed
    top  = elem.position().top + opts.offset.top
    left = elem.position().left + opts.offset.left

    newElem = $("<span/>", {
      class: [opts.markerClass, 'sc-mark'].join ' '
    }).insertBefore elem

    newElem.zIndex(999)

    top  -= opts.markerHeight * 1.3
    left += (elem.outerWidth() - newElem.outerWidth()) / 2

    console.log "top: #{top} left: #{left}"
    newElem.css {
      position: 'absolute'
      top:      "#{ Math.floor(top) }px"
      left:     "#{ Math.floor(left) }px"
    }

# defaults
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
  $(this).prev('.sc-mark').remove()