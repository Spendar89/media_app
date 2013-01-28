class MediaController < ApplicationController
  def create
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      seconds = params[:seconds]
      if /youtube/.match(params[:url])
        video = Video.new(params[:url], seconds, params[:page_id], params[:title], params[:description])
        video.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{video.id}"
      elsif /soundcloud/.match(params[:url])
        sound = Sound.new(params[:url], seconds, params[:page_id], params[:title], params[:description])
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
  
  def preview
    @url = params[:url]
    @seconds = Medium.seconds(params[:start_minutes], params[:start_seconds])
    @page_id = params[:page_id]
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      if /youtube/.match(params[:url])
        @preview_title = Video.yt_title(params[:url])
        @preview_description = Video.yt_description(params[:url])
      elsif /soundcloud/.match(params[:url])
        @preview_title = Sound.title(params[:url])
        @preview_description = Sound.description(params[:url])
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
    if params[:page_id] == "index"
      @page = nil
      @media = Medium.all_redis
    else
      @page = Page.find(params[:page_id])
      @media = @page.media
    end 
    @after = params[:after].to_i if params[:after] != 'none'
    @before = params[:before].to_i if params[:before] != 'none'
    @updated_media, @scroll_media = [], []
    @media.each do |medium|
      if @after.is_a? Integer
        @updated_media << medium if medium['uploaded'].to_i > @after + 1 && !medium["type"].nil?
      else
        @scroll_media << medium if medium['uploaded'].to_i  < @before && !medium["type"].nil?
      end
    end
  end
end
