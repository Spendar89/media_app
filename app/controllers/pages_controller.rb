class PagesController < ApplicationController
  
  def create
    @category = Category.find_or_create_by_name(params[:category_name])
    @page = current_user.pages.new(:category_id => @category.id, :name => params[:name])
    redirect_to page_path(@page) if @page.save
  end
  
  def show
    @page = Page.find(params[:id])
    @media = @page.media
  end
  
  
  
end
