// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .

$(function(){
    var GAME_OVER = false;
    
   $(document).on('click','[id^="cell_number"]',function(){
      if ( $(this).hasClass( "cross") || $(this).hasClass( "round") || GAME_OVER ) {
        return false;  
      } 
      
      var id = $(this).attr("val");
      var that = this;
      $(this).addClass("cross");
      $.ajax({
        type: 'POST',
        url: '/welcome/create',
        data: { 'id' : id },
        dataType: 'json',
        success: function(jsonData) {
          $("#cell_number_"+jsonData.host_choose_numbser).addClass("round");
          console.log(jsonData)
          
          if(jsonData.host_won) {
              GAME_OVER = true;
              alert("Sorry!!! You have lost the game");
              return false;
          }
          if(jsonData.user_won) {
              GAME_OVER = true;
              alert("Congratz!! You have won the game");
              return false;
          }
          
        },
      error: function() {
        alert('Error loading PatientID=' + id);
      }
        });
    }); 
    
    $(document).on('click','#reset',function(){
      GAME_OVER = false;
      return true;
    });
});