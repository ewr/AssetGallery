module AssetGallery
  class HomeController < ::AssetGallery::ApplicationController
        
    def index
      @sets = AssetGallery::Set.published.is_public.page(params[:page] || 1).per(12)
    end
  end
end
