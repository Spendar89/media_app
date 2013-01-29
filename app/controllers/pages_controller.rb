class PagesController < ApplicationController
  
  def index
    @category = Category.find(params[:category_id])
    @pages = @category.pages
  end
  
  def create
    @page = current_user.pages.new(:category_id => params[:category_id], :name => params[:name])
    redirect_to page_path(@page) if @page.save
  end
  
  def show
    @recent_pages = Page.all
    @page = Page.find(params[:id])
    @media = @page.media.paginate(:page => params[:page], :per_page => 12)
  end
end
