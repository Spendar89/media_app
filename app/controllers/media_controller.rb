class MediaController < ApplicationController
  def create
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      seconds = Medium.seconds(params[:start_minutes], params[:start_seconds])
      if /youtube/.match(params[:url])
        video = Video.new(params[:url].split('v=')[-1], seconds, params[:page_id])
        video.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{video.id}"
      elsif /soundcloud/.match(params[:url])
        sound = Sound.new(params[:url], seconds, params[:page_id])
        sound.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{sound.id}"
      else
        @error = "Please Enter a Valid Soundcloud or Youtube Url!"
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  def index
    @recent_pages = Page.all 
    @auth = request.env["omniauth.auth"]
    @media = []
    @media = Medium.all_redis[0..8] unless Medium.all_redis.nil?
  end
  
  def flush_db
    Video.flush_db if params[:password] == "guccimane"
    redirect_to :root 
  end
  
  def shows
  end
  
  def poll_redis
    @after = params[:after].to_i if params[:after] != 'none'
    @before = params[:before].to_i if params[:before] != 'none'
    @videos = Video.all_redis
    @updated_videos, @scroll_videos = [], []
    @videos.each do |video|
      if @after.is_a? Integer
        @updated_videos << video if video['uploaded'].to_i > @after + 1 && !video["type"].nil?
      else
        @scroll_videos << video if video['uploaded'].to_i  < @before - 1 && !video["type"].nil?
      end
    end
  end
end
