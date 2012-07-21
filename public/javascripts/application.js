// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(function() {
    setTimeout(function() {
                 $(".notice").fadeOut(3000);             
               }, 5000);

    $("#tweets").tweet({
                         username: "my2centsmobi",
                         avatar_size: 32,
                         count: 10,
                         loading_text: "loading tweets..."
                       });
});
