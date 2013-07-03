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

  $('#idea_form_content').bind('hastext', function () {
    $('#post-button').removeClass('disabled').attr('disabled', false);
  });

  $('#idea_form_content').bind('notext', function () {
    $('#post-button').addClass('disabled').attr('disabled', true);
  });

  $('#idea_form_content').bind('textchange', function (event, previousText) {
    $('#characters-left').html( 140 - parseInt($(this).val().length) );
  });


  var ta = document.getElementById('idea_form_content');
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

function decorateIdeaFormPrivacy(sel) {
  $(sel).select2({
    width: '100%',
    minimumResultsForSearch: 3
  });
}

function decorateIdeaFormReminderOn(value, reminderOnSel) {

  // alert("change "+JSON.stringify({val:e.val, added:e.added, removed:e.removed}));
  switch(value)
  {
  case "1":
    // alert("0");
    $(reminderOnSel).hide();
    $(reminderOnSel).datepicker("destroy");
    $(reminderOnSel).select2('destroy');
    // hide field
    break;
  case "2":
    // alert("1-week");
    $(reminderOnSel).attr("placeholder", "eg: Monday");
    $(reminderOnSel).show();
    $(reminderOnSel).datepicker("destroy");
    $(reminderOnSel).select2({
      width: '100%',
      allowClear: false,
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
  case "3":
    // alert("3-month");
    $(reminderOnSel).attr("placeholder", "Day of the month (eg: 11)");
    $(reminderOnSel).show();
    $(reminderOnSel).datepicker("destroy");
    $(reminderOnSel).select2('destroy');
    break;
  case "4":
    // alert("3-season");
    $(reminderOnSel).attr("placeholder", "eg: in Summer");
    $(reminderOnSel).show();
    $(reminderOnSel).datepicker("destroy");
    $(reminderOnSel).select2({
      width: '100%',
      allowClear: false,
      data: [{id: 0, text: 'in Spring'},
             {id: 1, text: 'in Summer'},
             {id: 2, text: 'in Autumn'},
             {id: 3, text: 'in Winter'}
            ]
    });
    break;
  case "5":
    //alert("4-year");
    $(reminderOnSel).attr("placeholder", "Month and day (eg: 11/20)");
    $(reminderOnSel).show();
    $(reminderOnSel).datepicker("destroy");
    $(reminderOnSel).select2('destroy');
    break;
  default:
    $(reminderOnSel).attr("placeholder", "eg: 11/20/2014");
    $(reminderOnSel).show();
    $(reminderOnSel).select2('destroy');
    $(reminderOnSel).datepicker();
    // alert("default");
  }

}

function decorateIdeaFormRepeat(repeatSel, reminderOnSel) {
  $(repeatSel).select2({
    placeholder: "Repeat",
    width: '100%',
    allowClear: false
  });

  decorateIdeaFormReminderOn($(repeatSel).val(), reminderOnSel);

  $(repeatSel).on("change", function(e) {
    $(reminderOnSel).val(""); 
    decorateIdeaFormReminderOn(e.val, reminderOnSel)
  });
}

function decorateIdeaForm() {
  decorateIdeaFormPrivacy(".privacySelect");
  decorateIdeaFormRepeat("#idea_form_repeat", "#idea_form_reminder_on");
}

function decorateIdeaFormPopup() {
  decorateIdeaFormPrivacy(".privacySelectPopup");
  decorateIdeaFormRepeat("#existing_idea_form_repeat", "#existing_idea_form_reminder_on");
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
          script = data;
          eval(script);
        },
        'script');
}
