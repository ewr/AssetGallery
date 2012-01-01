AssetGallery::Engine.routes.draw do
  resources :sets do
    member do
      post :assets
    end
  end
  
  match '/' => 'home#index', :as => :home
end
