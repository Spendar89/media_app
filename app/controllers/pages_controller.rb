class PagesController < ApplicationController
  
  def index
    @category = Category.find(params[:category_id])
    @pages = @category.pages
  end
  
  def create
    @page = current_user.pages.create(:category_id => params[:category_id], :name => params[:name])
    @page.add_to_feed(current_user)
    redirect_to page_path(@page)
  end
  
  def show
    @page_score = current_user.reccomend_page_score(params[:id])
    @recent_pages = Page.all
    @page = Page.find(params[:id])
    @category_id = @page.category_id
    @media = @page.media.paginate(:page => params[:page], :per_page => 12)
  end
end
