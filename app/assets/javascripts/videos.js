function scrollLoad(){
	if ($('.pagination').length){
		$(window).scroll(function() {
			url = $('.pagination .next_page').attr('href').replace("&filtered=true", "")
			alert(url);
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

function keyNav(){
	var first = true
	var counter = -1
	$(document.documentElement).keyup(function (event) {
		var array = []
		$('.media_parent').each(function(){
			array.push($(this))
		});
		function SortByUploaded(a, b){
			var aUploaded = a.data('uploaded');
			var bUploaded = b.data('uploaded'); 
			return ((aUploaded < bUploaded) ? -1 : ((aUploaded > bUploaded) ? 1 : 0));
		}
		var boxes = array.sort(SortByUploaded).reverse();

		if (event.keyCode == 39) {
			counter += 1
		} else if (event.keyCode == 37) { 
			counter -= 1
		} else if (event.keyCode == 38){
			counter -= numColumns()
			
		}else if (event.keyCode == 40){
			counter += numColumns()
		}
		$('.selected').trigger('mouseout').removeClass('selected');
		$(boxes[counter]).trigger('mouseover').addClass('selected');	
	});
}

function numColumns(){
	var conWidth = $('#masonry-container').width();
	if (conWidth >= 1750){
		return 6
	}else if (conWidth >= 1460 && conWidth < 1750){
		return 5
	}else if (conWidth >= 1170 && conWidth < 1460){
		return  4
	}else if(conWidth < 1170 && conWidth >= 880){
		return  3
	}else if (conWidth < 880 && conWidth > 590){
		return 2
	}else{
		return 1
	}	
}

function deleteVideo(video_id){
	$('div[video_id='+video_id).remove();
}


function tokenInput() {
	$("#tag-search").tokenInput("/media/token_input", {
		preventDuplicates: true,
		hintText: false,
		searchingText: false,
		resultsFormatter: function(item){
			if (item.id[0] == "T"){
				return "<li style='margin-left: 2%'>" + "# " + item.name + "</li>"
			}else if (item.id[0] == "C"){
				return "<li>" + "<span class='glyph general' style='font-size: 16pt; margin-left: 1%'>c </span>" + item.name + "</li>"
			}
		},
		tokenFormatter: function(item){ 
					return "<li style='display: none'>" + "#"+item.name + "</li>"
					}, 
	     onAdd: function (item) {
			$('#masonry-container').children().remove();
			$('#selected-tags').append("<span class='label secondary filter-label'></span>");
			var label = $(".filter-label").last();
			if(item.id[0] == "C"){
				label.addClass("cat-filter");
				label.html("<span class='glyph general' style='font-size: 18pt; margin-left: 1%'>c </span>"+item.name + "<a id='"+item.id+"' href='#' class='token-input-delete-token-facebook'>×</a>")
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
			$('#token-input-tag-search').attr('placeholder', 'Filter By Category or Tag');
		},
		onDelete: function (item) {
			 $('#masonry-container').children().remove();
	         $.get("/media.js?filtered=true&page=1"+ tokenParams());
	     }
	});
}


$(document).ready(function(){
	$('#masonry-container').masonry({
		itemSelector: '.box',
		isAnimated: false
	});
	scrollLoad();
	disableThumbs();
	mediaZoom();
	notLoggedIn();
	// keyNav();
	pollRedis("false");
	tokenInput();
});

$(document).ajaxComplete(function(){
	$('.loader').fadeOut();
	disableThumbs();
	mediaZoom();
	notLoggedIn();
	// keyNav();
})



