AssetGallery::Engine.routes.draw do
  resources :sets do
    member do
      match '/:asset/:slug' => "sets#show_asset", :as => :show_asset
      post :assets
    end
  end
  
  match '/' => 'home#index', :as => :home
end
