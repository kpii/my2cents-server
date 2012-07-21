var $my2cents = {};

$my2cents.pollForNewComments = function() {
  $.get('/comments/recent', function(data) {
          $('#comments').prepend(
            $('li', $(data)).not(function() {
                                      return $('#' + this.id).size();
                           }).
              css({'display' : 'none'}).
              fadeIn());
        });

  setTimeout($my2cents.pollForNewComments, 5 * 1000);
};

$(function() {
    $my2cents.pollForNewComments();
});
