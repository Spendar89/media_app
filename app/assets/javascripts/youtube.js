(function(){
	var s = document.createElement("script");
	s.src = "http://www.youtube.com/player_api";
	var before = document.getElementsByTagName("script")[0];
	before.parentNode.insertBefore(s, before);
})();

function onYouTubeIframeAPIReady() {
	$('.yt_parent').each(function(){
		var newPlayer = new YouTubePlayer($(this));
		newPlayer.ready();
	});
}

function ajaxYouTubeLoad() {
	$('.poll-redis').each(function(){
		$(this).removeClass('poll-redis');
		var newPlayer = new YouTubePlayer($(this));
		newPlayer.ready();
	});
}

var YouTubePlayer = function(parentDiv){

	this.parentDiv = parentDiv;
	this.id = parentDiv.children('.video-row').children('.yt-video-div').children('.yt-video').attr('id');
	var playerId = this.id;

	this.ready = function(){
		new YT.Player(playerId, {
			events: {
				'onReady': onPlayerReady,
				'onStateChange': onPlayerStateChange,
				'onError': onPlayerError
			}
		});
	};

	var loadVideo = function(player){
		player.setVolume(0);
		parentDiv.addClass('loading');	
		player.playVideo();
	}

	var onPlayerHover = function(player){
		parentDiv.hover(function(){
			$('.selected').trigger('mouseout').removeClass('selected');
			player.seekTo(parentDiv.data("start"), 'false');	
			player.playVideo();
			player.setVolume(50);
		},
		function(){
			player.pauseVideo();
		});
	}

	var onPlayerReady = function(event){ 
		var player = event.target;
		loadVideo(player);
		onPlayerHover(player);	
	}

	var onPlayerError =	function(event){
		event.target.pauseVideo();
	}

	var onPlayerStateChange = function(event){
		var player = event.target
		if (event.data == YT.PlayerState.PLAYING && parentDiv.hasClass('loading')){
			player.pauseVideo();
			parentDiv.removeClass('loading');
		}
		else if (event.data == YT.PlayerState.PAUSED){
			parentDiv.find('.overlay').fadeOut();	
		}
	}		
};









