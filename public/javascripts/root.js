var $my2cents = {};

$(function() {
    $("li.new_comment").one('click', function() {
                                var form = $("form", this);
                                var li = form.parents("li.new_comment");
                                $("p, img", this).remove();
                                form.show();
                                $("textarea", form).focus();

                                form.submit(function() {
                                              li.load(
                                                form.attr('action'),
                                                form.serializeArray(),
                                                function() {
                                                  li.removeClass("new_comment");
                                                  form.hide();
                                                }
                                              );

                                              return false;
                                            });

                              });
});
