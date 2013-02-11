class MediaController < ApplicationController
  def create
    if current_user.nil?
      @error = "You Must Be Logged-in To Submit a Link!"
    else
      @page_id = params[:page_id]
      @category_id = params[:category_id]
      tags_array = params[:tags].split(",").map!{|tag| tag.strip.downcase}
      puts "tags_array_test: #{tags_array}"
      seconds = params[:seconds]
      if /youtube/.match(params[:url])
        video = Video.new(params[:url], seconds, @page_id, @category_id, tags_array, params[:title].gsub("'", ""), params[:description])
        video.add_redis(current_user)
        @new_media = $redis.hgetall "media:#{video.id}"
      elsif /soundcloud/.match(params[:url])
        sound = Sound.new(params[:url], seconds, @page_id, @category_id, tags_array, params[:title].gsub("'", ""), params[:description])
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
  
  def destroy
    @id = params[:id]
    @page_id = $redis.hget "media:#{@id}", "page_id"
    @tags = $redis.hget "media:#{@id}", "tags"
    @user_id = $redis.hget "media:#{@id}", "user_id"
    if current_user.id == @user_id.to_i || current_user.uid.to_i == 1092240216
      @tags.split(",").each{ |tag|  $redis.srem "tag:#{tag}", @id }
      $redis.del "media:#{@id}"
      $redis.zrem "media:by_upload", @id
      $redis.zrem "page:#{@page_id}:media:by_upload", @id
      $redis.zrem "user:#{current_user.id}:media:by_upload", @id
      $redis.zrem "media:by_score", @id
      $redis.srem "media:youtube", @id
      $redis.srem "category:#{category_id}", @id
    end
  end
  
  def preview
    @url = params[:url]
    @seconds = Medium.seconds(params[:start_minutes], params[:start_seconds])
    @page_id = params[:page_id]
    @category_id = Page.find(params[:page_id])[:category_id]
    @tags = ""
    if current_user.nil?
      @user_error = true
    else
      if /youtube/.match(params[:url]) && /v=/.match(params[:url])
        @preview_title = Video.yt_title(params[:url])
        @preview_description = Video.yt_description(params[:url])
      elsif /soundcloud/.match(params[:url])
        @preview_title = Sound.title(params[:url])
        @preview_description = Sound.description(params[:url])
      else
        @url_error = true
      end
    end
    respond_to do |format|
      format.js
    end 
  end
  
  def index
    @recent_pages = Page.all
    @filtered = true if params[:filtered]
    params[:category] ? media_ids = Medium.filtered_by_category(Category.find_by_name(params[:category]).id) :  media_ids = Medium.all_ids
    media_ids = Medium.filtered_by_tags(media_ids, params[:tags]) if params[:tags]
    @media = Medium.find_all(media_ids).sort{|x,y| y["uploaded"].to_i <=> x["uploaded"].to_i }.paginate(:page => params[:page], :per_page => 12)
    @ranked_pages = current_user.ranked_pages.reverse[0..9] unless current_user.nil?
    @trending_tags = Tag.ranked[0..9]
  end
  
  def poll_redis
    most_recent_id = params[:most_recent_id]
    most_recent_rank = $redis.zrank "media:by_upload", most_recent_id
    category_id = Category.find_by_name(params[:category]).id
    added_ids = $redis.zrange "media:by_upload", most_recent_rank + 1, -1
    added_ids.map!{|id| id if Medium.has_category?(id, category_id)} if params[:category]
    added_ids = Medium.filtered_by_tags(added_ids, params[:tags]) if params[:tags]
    @new_media = Medium.find_all(added_ids)[0..2]
  end
  
  def search
     @query = params[:query]
      @media = Medium.search_results(@query)
      @users = User.where('name ILIKE ?', "%#{params[:query]}%")
      @pages = Page.where('name ILIKE ?', "%#{params[:query]}%")
      @categories = Category.where('name ILIKE ?', "%#{params[:query]}%")
  end
        
  def token_input
    @q = params[:q]
    @tags = Tag.all
    @categories = Category.all
    @json_array = []
    @tags.each do |tag|
        @json_array << {:id => "T_#{rand(1000000)}", :name => tag } if /#{@q}/.match(tag)
    end
    @categories.each do |cat|
       @json_array << {:id => "C_#{rand(1000000)}", :name => cat.name } if /#{@q}/.match(cat.name)
    end
    respond_to do |format|
      format.json { render :json => @json_array.to_json }
    end
  end
  
  def flush_db
    Video.flush_db if params[:password] == "guccimane"
    redirect_to :root 
  end
  
  def media_zoom
    @medium_id = params[:id]
    @medium = $redis.hgetall "media:#{@medium_id}"
    @comments = $redis.zrevrange "media:#{@medium_id}:comments:by_date", 0, -1
    @comments.map!{|id| Comment.find(id)}
  end
  

end
