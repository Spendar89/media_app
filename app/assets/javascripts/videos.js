

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


$(document).ready(function(){
	$('#masonry-container').masonry({
		itemSelector: '.box',
		isFitWidth: true,	
	});
	scrollLoad();
	setTimeout(function(){
		$('#masonry-container').addClass('transitions-enabled');
	}, 2000);
});



