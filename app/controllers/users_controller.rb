class UsersController < ApplicationController
  def show
    @recent_pages = Page.all 
    @user = User.find(params[:id])
    @user_likes = @user.facebook
    @media = @user.media.paginate(:page => params[:page], :per_page => 12)
    @feed = []
    feed_array = $redis.zrevrange "user:#{@user.id}:feed", 0, -1
    feed_array[0..4].each{ |feed| @feed << feed }
  end
  
  def thumbs_up
    @media_id = params[:media_id]
    current_user.vote_up(@media_id)
  end
  
  def thumbs_down
    @media_id = params[:media_id]
    current_user.vote_down(@media_id)
  end
  

  
end

