setTimeout(function(){
	$('#masonry-container').addClass('transitions-enabled');
}, 5000);

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
	$(window).scroll(function(e) {
		e.preventDefault();
	   if($(window).scrollTop() + $(window).height() == $(document).height()) {
		 var before = $(".box").last().data("uploaded");
		 $.getScript("/videos/poll_redis.js?after=none&before=" + before);
		 $('#masonry-container').removeClass('transitions-enabled');
	   }
	});
}

$(document).ready(function(){
  	$(function(){  
	  $('#masonry-container').masonry({
	    itemSelector: '.box',
	    columnWidth: 100,
	    isAnimated: !Modernizr.csstransitions,
	    isFitWidth: true
	  });
	});
	scrollLoad();	
});

