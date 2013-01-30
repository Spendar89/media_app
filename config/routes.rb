YoutubeApp::Application.routes.draw do
  
  mount Foundation::Icons::Rails::Engine => '/fi'
  
  
  resources :users do
    member do
      get :show
      post :thumbs_up
      post :thumbs_down
    end
  end
  


  resources :media do
    collection do
      get :poll_redis
      post :flush_db
      match :preview
      get :search
    end
  end
  
  get 'tags/:tag', to: 'media#index', as: :tag


  resources :pages do
    collection do
      get :index
    end
  end


  resources :sounds


  resources :videos 

  root :to => 'media#index'

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  
end
