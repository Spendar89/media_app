YoutubeApp::Application.routes.draw do
  
  resources :media do
    collection do
      get :poll_redis
      post :flush_db
      match :preview
      match :search
    end
  end
  
  get 'tags/:tag', to: 'media#index', as: :tag


  resources :pages


  resources :sounds


  resources :videos 

  root :to => 'media#index'

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  
end
