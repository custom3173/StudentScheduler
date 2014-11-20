jQuery(window).load ->

  # color picker stuff

  # place a marker to highlight selected color
  $('.student_color').buttonset().change ->
    $(this).find('.ui-button').unmark()
    $(this).find('.ui-state-active').mark()

  # set the color options in student profile
  $('.student_color input[type="radio"]').each ->
    $(this).next('label').css {
      'background': $(this).val()
    }
    # place marker on previously selected color at page load
    if $(this).attr('checked') == 'checked'
      $(this).next('label').mark()

  # correct buttonset's curved edges for linewraps
  previous = null
  $('.student_color .ui-button').each ->
    if previous and previous.position().top < $(this).position().top
      previous.addClass 'ui-corner-right'
      $(this).addClass 'ui-corner-left'
    previous = $(this)