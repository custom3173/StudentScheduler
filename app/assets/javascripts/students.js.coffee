jQuery(window).load ->
  # place a marker to highlight selected color
  $('#color-selector').buttonset().change ->
    $(this).find('.ui-button').unmark()
    $(this).find('.ui-state-active').mark()

  # set the color options in student profile
  $('#color-selector input[type="radio"]').each ->
    $(this).next().css {
      'background': $(this).val()
    }

  # correct buttonset's curved edges for linewraps
  previous = null
  $('#color-selector .ui-button').each ->
    if previous and previous.position().top < $(this).position().top
      previous.addClass 'ui-corner-right'
      $(this).addClass 'ui-corner-left'
    previous = $(this)