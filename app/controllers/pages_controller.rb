class PagesController < ApplicationController
  
  def index
    @category = Category.find(params[:category_id])
    @pages = @category.pages
    media = []
    @pages.each do |page|
      media << page.media
    end
    @media = media.flatten.paginate(:page => params[:page], :per_page => 12)
  end
  
  def create
    @page = current_user.pages.create(:category_id => params[:category_id], :description => params[:description].gsub("'", "\\\\'"), :name => params[:name].gsub("'", "\\\\'"))
    @page.add_to_feed(current_user)
    @page.add_redis
    redirect_to page_path(@page)
  end
  
  def follow
     page = Page.find(params[:page])
     current_user.follow_page(page)
  end
  
  def show
    @page_score = current_user.reccomend_page_score(params[:id]) unless current_user.nil?
    @recent_pages = Page.all
    @page = Page.find(params[:id])
    @category_id = @page.category_id
    @media = @page.media.paginate(:page => params[:page], :per_page => 12)
  end
end
