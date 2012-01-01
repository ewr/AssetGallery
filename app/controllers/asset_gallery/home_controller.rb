module AssetGallery
  class HomeController < ApplicationController
        
    def index
      @sets = AssetGallery::Set.published.is_public
    end
  end
end
