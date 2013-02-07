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
				'onReady': createYTEvent(playerId),
				'onStateChange': onPlayerStateChange(playerId),
				'onError': onPlayerError
			}
		});
	});
}

function createYTEvent(playerId){ 
	return function (event) {
		var parent_div = $('#'+playerId).parents('.yt_parent');
		var player = event.target;
		player.mute();
		parent_div.addClass('loading');	
		player.playVideo();
		parent_div.hover(function(){
				$('.selected').trigger('mouseout').removeClass('selected');
				player.seekTo(parent_div.data("start"), 'false');	
				player.playVideo();
				player.unMute();
		},
			function(){
				player.pauseVideo();
		});
		}
	}
	
function onPlayerError(event){
	event.target.pauseVideo();
}

function  onPlayerStateChange(playerId){
		return function (event) {
			var parent_div = $('#'+playerId).parents('.yt_parent');	
			var player = event.target
			if (event.data == YT.PlayerState.PLAYING && parent_div.hasClass('loading')){
				player.pauseVideo();
				parent_div.removeClass('loading');
			}
			else if (event.data == YT.PlayerState.PAUSED){
				parent_div.find('.overlay').fadeOut();	
			}	
	}
}













