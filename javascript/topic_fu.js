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
  
  $('a.compare').click(function(){
    var form = $('#revision_select_form');
    form.toggleClass('visible').toggle('slow', function(){
      if(form.hasClass('visible')) {
        $('a.compare').text('Hide menu');
      } else {
        $('a.compare').text('Compare');
      }
    });
    return false;
  });
  
  $('a.no_profile').click(function(){
    alert("No luck... this user hasn't set up a profile. You should create yours!");
    return false;
  });

  $('#teasers a').click(function(){
    alert('Wait a minute! You gotta sign up first!');
    return false;
  });
  
  $('a.delete').click(function(){
    confirm("Are you sure you want to delete?");
  });

  $(window).load(function(){
    setInterval(function() {
      $('p.flash').fadeOut('slow');
    }, 3500);
  });
});
