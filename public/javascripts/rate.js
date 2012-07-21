$(function() {
    $("#rating form").hide().
      after($("<button class='like'>like</button><button class='dislike'>dislike</button>"));

    $("#rating button").
      addClass("ui-state-default ui-corner-all ui-priority-secondary").
      hover(function() { $(this).toggleClass("ui-state-hover"); } );

    var neutral = $("#rating input[value=''][type=radio]");
    var like = $("#rating input[value='like'][type=radio]");
    var dislike = $("#rating input[value='dislike'][type=radio]");

    var updatePressed = function() {
      $("#rating button.like").toggleClass('ui-state-active', like.attr('checked'));
      $("#rating button.dislike").toggleClass('ui-state-active', dislike.attr('checked'));
    };

    updatePressed();

    $("#rating button").
      click(function() {
              var target = ($(this).hasClass('like') ? like : dislike);

              if(target.attr('checked')) {
                neutral.attr('checked', true);
              } else {
                target.attr('checked', true);
              }
              updatePressed();

              $("#rating_status").
                html("loading...").
                load(
                  $("#rating form").attr('action'),
                  $("#rating form").serializeArray(),
                  function() {
                    $("#rating .question").hide();
                  }
                );

              return false;
            });
  });
