$(document).ready(function(){
    
  $(window).load(function(){
    setInterval(function() {
      $('p.flash').fadeOut('slow');
    }, 5000);
  });
});
