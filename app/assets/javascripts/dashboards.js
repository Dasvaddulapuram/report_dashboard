// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$( document ).on('turbolinks:load', function() {
  // $('.datepicker').datepicker({
  //   format: 'dd/mm/yyyy',
  //   endDate: '-1d',
  //   autoclose: true
  // });

  $('.filter-report').on('change', function(){
    var filter_type = $("#report_type").val();

    if(filter_type == "Monthly Report")
    {  
      $("#week").hide();
      $("#month").show();
      $("#start_date").hide();
      $("#start_date").val('');
      $("#week").val('');   
      $("#year").show();
    }else if (filter_type == "Weekly Report"){
      $("#week").show();
      $("#month").hide();
      $("#start_date").hide();
      $("#start_date").val('');
      $("#month").val('');
      $("#year").val('');
      $("#year").hide();
    }else if (filter_type == "Daily Report"){
      $("#week").hide();
      $("#month").hide();
      $("#start_date").show();
      $("#week").val('');
      $("#month").val('');
      $("#year").val('');
      $("#year").hide();
    }else{
      $("#week").val('');
      $("#month").val('');
      $("#start_date").val('');
      $("#week").hide();
      $("#month").hide();
      $("#start_date").hide();
      $("#year").hide();
    }
  });

  $('#submit-button').on('click', function(){
    var system_group = $("#system_group").val();
    var week =  $("#week").val();
    var month =   $("#month").val();
    var start_date = $("#start_date").val();
    var report_type = $("#report_type").val();
    var year = $("#year").val();
    if (report_type == "") {
      alert("Please select report type")
      return false;
    }else if (week == "" && month == "" && start_date == "")
    {
      alert("Please select month or week number or date")
      return false;
    }
    else if ( (report_type == "Weekly Report" || report_type == "Monthly Report") && year == '')
    {
      alert("Please select year")
      return false;
    }
    else if (system_group == ""){
      alert("Please select any system group")
      return false;
    }
  })

  var month_value = $("#month").val();
  var week_value = $("#week").val();
  var start_date_value = $('#start_date').val();
  var year_value = $('#year').val();
  if(month_value != "")
  {
    $("#month").show();
  }else if(week_value != "")
  {
    $("#week").show();
  }else if (start_date_value != "")
  {
    $("#start_date").show();
  }else if(year_value != "")
  {
    $("#year").show();
  }

  $('.datatable').DataTable( {
    "ordering": false,
    "lengthMenu": [50, 75, 100]
  } );
  $(".dataTables_filter").hide();

});