jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

$(function() {
    /* UI related JS below here */

    // initialize jquery ui elements
    $('button, input:submit').button();

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

    // don't allow permanant and absent checkboxes
    // to both be selected in new schedule form
    $('#schedule_permanent').change(function() {
        if (this.checked) {
            $('#schedule_absent').prop('checked', false);
        }
    });
    $('#schedule_absent').change(function() {
        if (this.checked) {
            $('#schedule_permanent').prop('checked', false);
        }
    });

});
