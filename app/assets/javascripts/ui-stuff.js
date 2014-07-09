jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

$(function() {
  /* UI related JS below here */

  // initialize jquery ui elements
  $('button, input:submit, .button').button();

  // buttons w/ icons
  $('a.edit').button({
    icons: {
      primary: "ui-icon-document"
    }
  });

  $('a.delete').button({
    icons: {
      primary: "ui-icon-trash"
    }
  });

  // buttonsetify form elements (schedule form)
  $('.jq-buttonset').buttonset();

  // use datepickers for schedule form dates
  $( "#schedule_start_date" ).datepicker({
    dateFormat: "yy-mm-dd",
    defaultDate: "+1w",
    changeMonth: true,
    numberOfMonths: 3,
    onClose: function( selectedDate ) {
      $( "#schedule_end_date" ).datepicker( "option", "minDate", selectedDate );
    }
  });
  $( "#schedule_end_date" ).datepicker({
    dateFormat: "yy-mm-dd",
    defaultDate: "+1w",
    changeMonth: true,
    numberOfMonths: 3,
    onClose: function( selectedDate ) {
      $( "#schedule_start_date" ).datepicker( "option", "maxDate", selectedDate );
    }
  });

  // accordionize the students' schedules lists
  $(".schedule-accordion").accordion({
    collapsible: true,
    active: false
  });

  // use datepicker for calender date selection
  $('#calendar-date').datepicker({
    dateFormat: "yy-mm-dd"
  });

  // add tooltips to the calendar
  $(document).tooltip();

  // hide the weekend schedules in the calendar
  $('.weekend').hide();
  $('#rows-container').width('770px');
  $('#Show_weekend_schedules').change(function() {
    if (this.checked) {
      $('.weekend').show();
      $('#rows-container').width('1024px');
    } else {
      $('.weekend').hide();
      $('#rows-container').width('770px');
    }
  });
});
