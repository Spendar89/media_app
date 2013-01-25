
	function getFrameID(id){
		var elem = document.getElementById(id);
		if (elem) {
			if(/^iframe$/i.test(elem.tagName)) return id; //Frame, OK
			// else: Look for frame
			var elems = elem.getElementsByTagName("iframe");
			if (!elems.length) return null; //No iframe found, FAILURE
			for (var i=0; i<elems.length; i++) {
				if (/^https?:\/\/(?:www\.)?youtube(?:-nocookie)?\.com(\/|$)/i.test(elems[i].src)) break;
			}
			elem = elems[i]; //The only, or the best iFrame
			if (elem.id) return elem.id; //Existing ID, return it
			// else: Create a new ID
			do { //Keep postfixing `-frame` until the ID is unique
				id += "-frame";
				} while (document.getElementById(id));
				elem.id = id;
				return id;
			}
			// If no element, return null.
			return null;
		}

		// Define YT_ready function.
		var YT_ready = (function(){
			var onReady_funcs = [], api_isReady = false;
			/* @param func function     Function to execute on ready
			* @param func Boolean      If true, all qeued functions are executed
			* @param b_before Boolean  If true, the func will added to the first
			position in the queue*/
			return function(func, b_before){
				if (func === true) {
					api_isReady = true;
					for (var i=0; i<onReady_funcs.length; i++){
						// Removes the first func from the array, and execute func
						onReady_funcs.shift()();
					}
				}
				else if(typeof func == "function") {
					if (api_isReady) func();
					else onReady_funcs[b_before?"unshift":"push"](func); 
				}
			}
			})();
			// This function will be called when the API is fully loaded
			function onYouTubePlayerAPIReady() {YT_ready(true)}

			// Load YouTube Frame API
			(function(){ //Closure, to not leak to the scope
				var s = document.createElement("script");
				s.src = "http://www.youtube.com/player_api"; /* Load Player API*/
				var before = document.getElementsByTagName("script")[0];
				before.parentNode.insertBefore(s, before);
			})();
			
			var loading = true
			
			$(document).ready(function(){

				var players = {}; //Define a player storage object, to expose methods,
				//  without having to create a new class instance again.
				YT_ready(function() {
					$("iframe[id]").each(function() {
						var identifier = this.id;
						var frameID = getFrameID(identifier);
						if (frameID) { //If the frame exists
							players[frameID] = new YT.Player(frameID, {
								events: {
									"onReady": createYTEvent(frameID, identifier),
									"onStateChange": onytplayerStateChange(identifier, loading)
								}
							});
						}
					});
				});
				
				

				// Returns a function to enable multiple events
				function createYTEvent(frameID, identifier) {
					return function (event) {
						var parent_div = $('#'+identifier).parent('.yt_parent');	
						var player = players[frameID]; // Set player reference
						player.mute();
						player.playVideo();
						$(parent_div).hover(function(){
							player.seekTo(parent_div.data("start"), 'false');
							player.unMute();
							player.playVideo();	
						}, function(){
							player.pauseVideo();
						});
		
					}
				}
				
				function onytplayerStateChange(identifier, loading) {
					return function(event) {
						if( event.data == YT.PlayerState.PLAYING && loading == true){
							event.target.pauseVideo();
							loading = false
							var parent_div = $('#'+identifier).parent('.yt_parent');
							setTimeout(function(){
								parent_div.children('.overlay').fadeOut()
							}, 2000);
						}
					}	
				}
			});
				

	