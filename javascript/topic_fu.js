$(function(){
  
  $('a.add_comment').click(function(){
    var form = $('#comment_form');
    form.toggleClass('visible').toggle('slow', function(){
      if(form.hasClass('visible')) {
        $('a.add_comment').text('Hide comment form');
      } else {
        $('a.add_comment').text('Add comment');
      }
    });
    return false;
  });
  $(window).load(function(){
    setInterval(function() {
      $('p.flash').fadeOut('slow');
    }, 3500);
  });
});
