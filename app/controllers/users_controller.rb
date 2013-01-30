class UsersController < ApplicationController
  def show
    @auth = request.env["omniauth.auth"]
    @recent_pages = Page.all 
    @user = User.find(params[:id])
    @media = @user.media.paginate(:page => params[:page], :per_page => 12)
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

