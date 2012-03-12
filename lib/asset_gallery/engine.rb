module AssetGallery
  class Engine < Rails::Engine
    isolate_namespace AssetGallery
    
    # initialize our config hash
    config.asset_gallery = ActiveSupport::OrderedOptions.new
    
  end
end
