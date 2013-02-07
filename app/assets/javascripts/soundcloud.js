$(document).ready(function() {
	$(document).bind('soundcloud:onPlayerReady', function(event, data) {
	 
	  var mediaUri = data.mediaUri,
	
	  mediaId   = data.mediaId,
	  flashNode = event.target;
	  event.target.api_play();
	  event.target.api_seekTo($("#"+mediaId).data("start"));
	  setTimeout(function(){
	    event.target.api_pause();
		$("#"+mediaId).parents('.sc_parent').children('.sc_overlay').fadeOut();
	  }, 1);
	  
	  $("#"+mediaId).parents('.sc_parent').hover(function() {
			$('.selected').trigger('mouseout').removeClass('selected');
			event.target.api_seekTo($("#"+mediaId).data("start"));
			event.target.api_play();
		}, function() {
			event.target.api_pause();
	  }); 
	});
});



