YoutubeApp::Application.routes.draw do
  
  resources :sounds


  resources :videos do
    collection do
      get :poll_redis
    end
  end


  root :to => 'videos#index'

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  
end
