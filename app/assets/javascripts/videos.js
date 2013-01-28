

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
	$(window).scroll(function() {
	   if($(window).scrollTop() + $(window).height() == $(document).height()) {
		 $('#masonry-container').removeClass('transitions-enabled')
		 var before = $(".box").last().data("uploaded");
		 var page_id = $('#masonry-container').data('page_id');
		 $.getScript("/media/poll_redis.js?after=none&before="+before+"&page_id="+page_id);
	   }
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
});



