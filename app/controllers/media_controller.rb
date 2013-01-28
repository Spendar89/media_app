class MediaController < ApplicationController
  def create
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      tags_array = params[:tags].split(",").map!{|tag| tag.strip.downcase}
      puts "tags_array_test: #{tags_array}"
      seconds = params[:seconds]
      if /youtube/.match(params[:url])
        video = Video.new(params[:url], seconds, params[:page_id], tags_array, params[:title], params[:description])
        video.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{video.id}"
      elsif /soundcloud/.match(params[:url])
        sound = Sound.new(params[:url], seconds, params[:page_id], tags_array, params[:title], params[:description])
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
    category_id = Page.find(params[:page_id])[:category_id]
    @tags = "#{Category.find(category_id)[:name]}"
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
    if params[:tag]
      @tag = params[:tag]
      @media = Tag.find_all(@tag)
    else   
      @recent_pages = Page.all 
      @auth = request.env["omniauth.auth"]
      @media = []
      @media = Medium.all_redis[0..8] unless Medium.all_redis.nil?
    end
  end
  
  def search
    @query = params[:query]
    @media = Medium.search_results(@query)
    @users = User.where('name LIKE ?', "%#{params[:query].split(" ").map{|name| name[0].upcase + name[1..-1]}.join(" ")}%")
    @pages = Page.where('name LIKE ?', "%#{params[:query].downcase}%")
    @categories = Category.where('name LIKE ?', "%#{params[:query].downcase}%")
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
