class VideosController < ApplicationController
  
  def create
    seconds = Video.seconds(params[:start_minutes].to_i, params[:start_seconds].to_i)
    if params[:type] == "youtube"
      @video = Video.new(:url => params[:url].split('v=')[-1], :start => seconds, :uploaded => Time.now.to_i)
      @video.add_redis(current_user)
      @video = $redis.hgetall "youtube:#{@video.yt_id}"
    else
      @video = Sound.new(params[:url], seconds)
      @video.add_redis(current_user)
      @video = $redis.hgetall "youtube:#{@video.id}"
    end
    respond_to do |format|
      format.js
    end
  end
  
  def index 
    @auth = request.env["omniauth.auth"]
    @videos = []
    @videos = Video.all_redis[0..8] unless Video.all_redis.nil?
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
        @scroll_videos << video if video['uploaded'].to_i  < @before && !video["type"].nil?
      end
    end
  end
  
end
