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
        $(this).height("30px");
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
