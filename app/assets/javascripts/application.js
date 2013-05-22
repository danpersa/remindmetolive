// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require select2
//### require_tree .
$( function() {

  //$("button, input:submit").button();


//  $(".alert-message").alert();
//  $(".alert-message").alert('close');
  $('#post-button').addClass('disabled').attr('disabled', true);

  $('#remind-textarea').bind('hastext', function () {
    $('#post-button').removeClass('disabled').attr('disabled', false);
  });

  $('#remind-textarea').bind('notext', function () {
    $('#post-button').addClass('disabled').attr('disabled', true);
  });

  $('#remind-textarea').bind('textchange', function (event, previousText) {
    $('#characters-left').html( 140 - parseInt($(this).val().length) );
  });

  $('#user_idea_idea_content').bind('hastext', function () {
    $('#post-button').removeClass('disabled').attr('disabled', false);
  });

  $('#user_idea_idea_content').bind('notext', function () {
    $('#post-button').addClass('disabled').attr('disabled', true);
  });

  $('#user_idea_idea_content').bind('textchange', function (event, previousText) {
    $('#characters-left').html( 140 - parseInt($(this).val().length) );
  });


  var ta = document.getElementById('user_idea_idea_content');
  if (ta != null) {
    ta.onfocus = function(){
      $(this).height("90px");
      //$(this).animate({ height: "90px" });
    }

    ta.onblur = function(){
      if (this.value == '') {
        $(this).height("16px");
        //$(this).animate({ height: "30px" }, 300);
      }
    }
  }
  initToolbars();
  /* $(document).foundationTopBar(); */
  $(document).foundationCustomForms();

  $(document).foundationTopBar({breakPoint:978,initialized:false,index:0});
  $('.toggle-topbar').click(function(){$('.top-bar').toggleClass('expanded');});
});

function addNotification(message, styleClass) {
  $("#flash-container").append(
    '<div class="alert-box ' + styleClass +'" data-alert="alert">' +
       '<a class="close" href="#">x</a>' + message +
    '</div>'
  );
  initAlertBoxes();
}

function decorateUserIdeaPrivacy() {
  $(".privacySelect").select2({
    width: '100%',
    minimumResultsForSearch: 3
  });
  $("#user_idea_repeat").select2({
    placeholder: "Repeat",
    width: '100%',
    allowClear: true,
    data: [{id: 0, text: 'Every day'},
         {id: 1, text: 'Every week on'},
         {id: 2, text: 'Every month on'},
         {id: 3, text: 'Every specified season'},
         {id: 4, text: 'Every year on'}
        ]
  });
  $('#user_idea_reminder_on').attr("placeholder", "eg: 11/20/2014");
  $('#user_idea_reminder_on').datepicker();

  $("#user_idea_repeat").on("change",
    function(e) { 

      // alert("change "+JSON.stringify({val:e.val, added:e.added, removed:e.removed}));
      $('#user_idea_reminder_on').val("");
      switch(e.val)
      {
      case "0":
        // alert("0");
        $("#user_idea_reminder_on").hide();
        $("#user_idea_reminder_on").datepicker("destroy");
        $("#user_idea_reminder_on").select2('destroy');
        // hide field
        break;
      case "1":
        // alert("1-week");
        $('#user_idea_reminder_on').attr("placeholder", "eg: Monday");
        $("#user_idea_reminder_on").show();
        $("#user_idea_reminder_on").datepicker("destroy");
        $("#user_idea_reminder_on").select2({
          width: '100%',
          allowClear: true,
          data: [{id: 0, text: 'Sunday'},
                 {id: 1, text: 'Monday'},
                 {id: 2, text: 'Tuesday'},
                 {id: 3, text: 'Wendesay'},
                 {id: 4, text: 'Thursday'},
                 {id: 5, text: 'Friday'},
                 {id: 6, text: 'Saturday'}
                ]
        });
        break;
      case "2":
        // alert("3-month");
        $('#user_idea_reminder_on').attr("placeholder", "Day of the month (eg: 11)");
        $("#user_idea_reminder_on").show();
        $("#user_idea_reminder_on").datepicker("destroy");
        $("#user_idea_reminder_on").select2('destroy');
        break;
      case "3":
        // alert("3-season");
        $('#user_idea_reminder_on').attr("placeholder", "eg: in Summer");
        $("#user_idea_reminder_on").show();
        $("#user_idea_reminder_on").datepicker("destroy");
        $("#user_idea_reminder_on").select2({
          width: '100%',
          allowClear: true,
          data: [{id: 0, text: 'in Spring'},
                 {id: 1, text: 'in Summer'},
                 {id: 2, text: 'in Autumn'},
                 {id: 3, text: 'in Winter'}
                ]
        });
        break;
      case "4":
        //alert("4-year");
        $('#user_idea_reminder_on').attr("placeholder", "Month and day (eg: 11/20)");
        $("#user_idea_reminder_on").show();
        $("#user_idea_reminder_on").datepicker("destroy");
        $("#user_idea_reminder_on").select2('destroy');
        break;
      default:
        $('#user_idea_reminder_on').attr("placeholder", "eg: 11/20/2014");
        $("#user_idea_reminder_on").show();
        $("#user_idea_reminder_on").select2('destroy');
        $("#user_idea_reminder_on").datepicker();
        // alert("default");
      }

  });
}

function decorateUserIdeaPrivacyPopup() {
  $(".privacySelectPopup").select2({
    width: '175px',
    height: '31px',
    minimumResultsForSearch: 3
  });
}

function addNotificationNotice(message) {
  addNotification(message, "notice");
}

function addNotificationSuccess(message) {
  addNotification(message, "success");
}

function initAlertBoxes() {
  $(".alert-box").delegate("a.close", "click", function(event) {
    event.preventDefault();
    $(this).closest(".alert-box").fadeOut(function(event){
      $(this).remove();
    });
  }); 
}

function initToolbars() {
  $('div.show-toolbar').hover(function() {
    $(this).find("div.toolbar").removeClass('invisible');
  }, function() {
    $(this).find("div.toolbar").addClass('invisible');
  });
}

function updateCurrentPage() {
  var currentUrl = $("meta[name=current-url]").attr("content"); 
  $.get(currentUrl,
        function(data) {
          script = $(data).text();
          eval(script);
        },
        'script');
}
