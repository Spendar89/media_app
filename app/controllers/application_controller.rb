class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user

  private

  def current_user
    if Rails.env.development?
      @current_user = User.first 
    else
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
  end
end
