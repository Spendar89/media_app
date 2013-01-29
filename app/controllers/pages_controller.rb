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
    @page = Page.find(params[:id])
    @media = @page.media[0..8]
  end
end
