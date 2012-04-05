module AssetGallery
  class ApplicationController < ::ApplicationController
    
    layout AssetGallery::Config.layout
    
    def asset_model
      AssetGallery::Config.asset_model
    end
    
    def require_admin
      if @current_user && @current_user.is_admin?
        return true
      else
        Rails.logger.debug("Failed to access admin area. User is #{@current_user}. Admin is #{@current_user.is_admin?}")
        flash[:notice] = "Requested path requires admin rights."
        redirect_to home_path()
      end
    end
  end
end
