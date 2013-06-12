
$(document).ready(function() {
  $("#idea_idea_list_tokens").select2({
    width: '100%'
  }).select2("val", jQuery.parseJSON($('#idea_idea_list_tokens_data').attr('data')));
});

