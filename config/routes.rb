YoutubeApp::Application.routes.draw do
  
  mount Foundation::Icons::Rails::Engine => '/fi'
  
  
  resources :users do
    collection do
      match :update_news_feed
    end
    member do
      get :show
      match :thumbs_up
      match :thumbs_down
      match :add_comment
    end
  end
  


  resources :media do
    collection do
      get :poll_redis
      post :flush_db
      match :preview
      get :search
      match :media_zoom
      match :token_input
      match :rank_pages
    end
  end
  
  get 'tags/:tag', to: 'media#index', as: :tag
  
  get 'comments/:comment', to: 'user#add_comment', as: :comment


  resources :pages do
    collection do
      get :index
    end
    member do
      match :follow
    end
  end


  resources :sounds


  resources :videos 

  root :to => 'media#index'

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  
end
