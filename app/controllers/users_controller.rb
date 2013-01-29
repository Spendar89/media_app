class UsersController < ApplicationController
  def show
    @recent_pages = Page.all 
    @user = User.find(params[:id])
    @media = @user.media.paginate(:page => params[:page], :per_page => 12)
  end
end
