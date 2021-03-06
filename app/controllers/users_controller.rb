class UsersController < ApplicationController
  def show
    @recent_pages = Page.all 
    @user = User.find(params[:id])
    @user_likes = @user.facebook
    @media = @user.media.paginate(:page => params[:page], :per_page => 12)
    @feed = []
    feed_array = $redis.zrevrange "user:#{@user.id}:feed", 0, -1
    feed_array[0..4].each{ |feed| @feed << feed }
    @feed = ["No Recent Activity"] if @feed.empty?
  end
  
  def like
    @media_id = params[:media_id]
    current_user.like(@media_id)
  end
  
  def add_comment
    @user = User.find(params[:id])
    @media_id = params[:media_id]
    @comment = @user.comments.create(:content => params[:comment], :media_id => @media_id)
    $redis.zadd "media:#{@media_id}:comments:by_date", Time.now.to_i, @comment.id
  end
  
  def update_news_feed
    if current_user
      current_story_medium_id = params[:medium_id]
      most_recent_ids = current_user.most_recent_page_updated_feed
      medium_id = most_recent_ids[0] if most_recent_ids
      @medium = Medium.find(medium_id) if medium_id != current_story_medium_id
      puts @medium
    end
  end
  

  
end

