module AssetGallery
  class HomeController < ::AssetGallery::ApplicationController
        
    def index
      @sets = AssetGallery::Set.published.is_public.paginate(
        :page => params[:page] || 1,
        :per_page => 12
      )
    end
  end
end
