(function(){
	var s = document.createElement("script");
	s.src = "http://www.youtube.com/player_api";
	var before = document.getElementsByTagName("script")[0];
	before.parentNode.insertBefore(s, before);
})();

function onYouTubeIframeAPIReady() {
	$('.yt-video').each(function(){
		var playerId = $(this).attr('id');
		var player;
		player = new YT.Player(playerId, {
			events: {
				'onReady': createYTEvent(playerId)
			}
		});
	});
}

function createYTEvent(playerId){ 
	return function (event) {
		var parent_div = $('#'+playerId).parents('.yt_parent');	
		var player = event.target // Set player reference
		player.mute();
		player.playVideo();
		player.setPlaybackQuality('small');
		setTimeout(function(){
			player.pauseVideo();
		}, 2000);
		setTimeout(function(){
			parent_div.find('.overlay').fadeOut();
		}, 3000);
			$(parent_div).mouseover(function(){
				$('.selected').trigger('mouseout').removeClass('selected');
				player.seekTo(parent_div.data("start"), 'false');
				player.unMute();	
				player.playVideo();	
			}).mouseout(function(){
				player.pauseVideo();
			});

		}
	}






