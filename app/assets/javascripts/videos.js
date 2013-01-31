

// $(function() {
//     setTimeout(updateVideos, 10000);
// });
// 
// function updateVideos(){
// 	var after = $(".videos_div").children(':first').data("uploaded");
// 	$.getScript("/videos/poll_redis.js?before=none&after=" + after)
// 	setTimeout(updateVideos, 10000);
// }


function scrollLoad(){
	if ($('.pagination').length){
		$(window).scroll(function() {
			url = $('.pagination .next_page').attr('href')
	   		if(url && $(window).scrollTop() > $(document).height() - $(window).height() - 50){
				$('#masonry-container').removeClass('transitions-enabled')
				$('.pagination').text("Fetching more products...")
				$.getScript(url)
				$(window).scroll()
	   		}
		});
	}
}

function disableThumbs(){
	$('.voted_up, .voted_down').removeAttr('href').click(function(e){
		e.preventDefault();
		return false;
	});
	upColor = $('.voted_up').css('color');
	downColor = $('.voted_down').css('color');
	$('.voted_up').children('span').hover(function(){
		$(this).css('color', upColor);
	});
	$('.voted_down').children('span').hover(function(){
		$(this).css('color', downColor);
	});
}

function mediaZoom(){
	$(".yt_parent, .invisible-overlay").click(function() {
		var videoId = $(this).attr('video_id');
		$.getScript("/media/media_zoom.js?id=" + videoId)
   });
}


$(document).ready(function(){
	$('#masonry-container').masonry({
		itemSelector: '.box',
		isFitWidth: true,	
	});
	scrollLoad();
	setTimeout(function(){
		$('#masonry-container').addClass('transitions-enabled');
	}, 2000);
	disableThumbs();
	mediaZoom();
});

$(document).ajaxComplete(function(){
	disableThumbs();
	mediaZoom();
})



