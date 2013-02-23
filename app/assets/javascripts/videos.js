function scrollLoad(){
	if ($('.pagination').length){
		$(window).scroll(function() {
			url = $('.pagination .next_page').attr('href').replace("&filtered=true", "")
	   		if(url && $(window).scrollTop() > $(document).height() - $(window).height()){
				$('.loader').fadeIn();
				$('.pagination').text("Fetching more products...");
				$.getScript(url);
				$(window).scroll();
				return false;
	   		}
		});
	}
}

function tokenParams(){
	var params = ""
    array = $('#tag-search').tokenInput("get");
 	$.each(array, function(i, n){
	  if (n.id[0] == "T"){
	  	params += ("&tags[]=" + n.name)
	  }else if (n.id[0] == "C"){
		params += ("&category=" + n.name)
	  }
    });
	return params
}

function pollRedis(){
		if($('#masonry-container').hasClass('polling-enabled')){
			setTimeout(function(){
				$.get("/media/poll_redis?most_recent_id=" + $('.media_parent').first().attr('video_id') + tokenParams());
			}, 10000);
		};
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
	$(".invisible-overlay").click(function() {
		var videoId = $(this).attr('video_id');
		$.getScript("/media/media_zoom.js?id=" + videoId)
   });
}

function notLoggedIn(){
	$('.not-logged-in').click(function(e){
		e.preventDefault();
		alert("Sorry, you must be logged in to do that.");
	});
}


function isScrolledIntoView(elem)
{
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + $(window).height();

    var elemTop = $(elem).offset().top;
    var elemBottom = elemTop + $(elem).height();

    return ((docViewTop < elemTop) && (docViewBottom > elemBottom))
}

function keyNav(){
	var first = true
	var counter = -1
	
	$(document.documentElement).keydown(function (event) {
	    var keyPressed = event.keyCode;
	    if(keyPressed == 39 || keyPressed == 37 || keyPressed == 38 || keyPressed == 40 ) {
	        return false;
	    }
	});
	
	$(document.documentElement).keyup(function (event) {
		
		var keyPressed = event.keyCode;
		if (keyPressed == 39 || keyPressed == 37 || keyPressed == 38 || keyPressed == 40 ){
			
			if(counter < -1){
				counter = -1
			};
			var array = []
			
			$('.media_parent').each(function(){
				array.push($(this));
			});
			function SortByUploaded(a, b){
				var aUploaded = a.data('uploaded');
				var bUploaded = b.data('uploaded'); 
				return ((aUploaded < bUploaded) ? -1 : ((aUploaded > bUploaded) ? 1 : 0));
			}
			var boxes = array.sort(SortByUploaded).reverse();
			if(first){
				counter +=1
				first = false
			}
			else if (keyPressed == 39) {
				counter += 1
			} else if (keyPressed == 37) { 
				counter -= 1
			} else if (keyPressed == 38){
				counter -= numColumns()
			
			}else if (keyPressed == 40){
				counter += numColumns()
			}
			$('.selected').trigger('mouseout').removeClass('selected');
			$(boxes[counter]).trigger('mouseover').addClass('selected')
		};	
	});
}

function numColumns(){
	var conWidth = $('#masonry-container').width();
	var cols = Math.floor(conWidth/220);
	
	if(cols < 4){
		cols = 4
	}
	return cols
}

function deleteVideo(video_id){
	$('div[video_id='+video_id).remove();
}

function triggerFilter(tag){
	var idValue = "T_"+Math.floor(Math.random()*1000000);
	$('#tag-search').tokenInput("add", {id: idValue, name: tag});	
}

function tokenInput() {
	$("#tag-search").tokenInput("/media/token_input", {
		preventDuplicates: true,
		hintText: false,
		searchingText: false,
		resultsFormatter: function(item){
			if (item.id[0] == "T"){
				return "<li style='margin-left: 2%'>" + "<span style='margin-right: 3%; font-size: 12pt; font-weight: bold'>#</span> " + item.name + "</li>"
			}else if (item.id[0] == "C"){
				return "<li>" + "<span class='glyph general' style='font-size: 12pt; margin-left: 1%'>c </span>" + item.name + "</li>"
			}
		},
		tokenFormatter: function(item){ 
					return "<li style='display: none'>" + "#"+item.name + "</li>"
					}, 
	     onAdd: function (item) {
			$('#masonry-container').children().remove();
			$('#selected-tags').append("<span class='label secondary filter-label' style='float: left; margin: 5px'></span>");
			var label = $(".filter-label").last();
			if(item.id[0] == "C"){
				label.addClass("cat-filter");
				label.html("<span class='glyph general' style='font-size: 14pt; margin-left: 1%'>c </span>"+item.name + "<a id='"+item.id+"' href='#' class='token-input-delete-token-facebook'>×</a>")
			}else{
				label.addClass("tag-filter");
				label.html("#"+item.name + "<a id='"+item.id+"'href='#' class='token-input-delete-token-facebook'>×</a>");
			}
			$("a#"+item.id).click(function(){
				$("#tag-search").tokenInput("remove", { id: item.id });
				$(this).parents().first().remove();
			});
	         $.get("/media.js?filtered=true&page=1"+ tokenParams());
	     },
		onReady: function(){
			$('#token-input-tag-search').attr('placeholder', 'Enter Category or Tag');
		},
		onDelete: function (item) {
			 $('#masonry-container').children().remove();
	         $.get("/media.js?filtered=true&page=1"+ tokenParams());
	     }
	});
}

function getRankedPages(){
	$.get("/media/rank_pages.js");
}

function updateNewsFeed(){
	setTimeout(function(){
		$.get("/users/update_news_feed.js?medium_id=" + $('.feed-story').attr('news-feed-id'));
	}, 10000);
}


$(document).ready(function(){
	$('#masonry-container').masonry({
		itemSelector: '.box',
		isAnimated: false
	});
	setTimeout(function(){ getRankedPages() }, 2000)
	scrollLoad();
	updateNewsFeed();
	disableThumbs();
	mediaZoom();
	notLoggedIn();
	// keyNav();
	pollRedis();
	tokenInput();
	$('.vertical-rule').css('height', $('.side-panel-div').height());
});

$(document).ajaxComplete(function(){
	$('.loader').fadeOut();
	disableThumbs();
	mediaZoom();
	notLoggedIn();
	// keyNav();
})



