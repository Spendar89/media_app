class MediaController < ApplicationController
  def create
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      @page_id = params[:page_id]
      tags_array = params[:tags].split(",").map!{|tag| tag.strip.downcase}
      puts "tags_array_test: #{tags_array}"
      seconds = params[:seconds]
      if /youtube/.match(params[:url])
        video = Video.new(params[:url], seconds, @page_id, tags_array, params[:title], params[:description])
        video.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{video.id}"
      elsif /soundcloud/.match(params[:url])
        sound = Sound.new(params[:url], seconds, @page_id, tags_array, params[:title], params[:description])
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
    @recent_pages = Page.all 
    if params[:tag]
      @tag = params[:tag]
      @media = Tag.find_all(@tag).paginate(:page => params[:page], :per_page => 12)
    else   
      @auth = request.env["omniauth.auth"]["user_info"]
      @media = Medium.all_redis.paginate(:page => params[:page], :per_page => 12)
    end
  end
  
  def search
    @query = params[:query]
    @media = Medium.search_results(@query)
    @users = User.where('name ILIKE ?', "%#{params[:query]}%")
    @pages = Page.where('name ILIKE ?', "%#{params[:query]}%")
    @categories = Category.where('name ILIKE ?', "%#{params[:query]}%")
  end
  
  def flush_db
    Video.flush_db if params[:password] == "guccimane"
    redirect_to :root 
  end
  
  def shows
  end
  
end
