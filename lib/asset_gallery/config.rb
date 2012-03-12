module AssetGallery
  module Config
    #DEFAULT_ASSET_MODEL = AssethostAsset
    
    class << self
            
      def asset_model(model=nil)
        @asset_model = model if model
        @asset_model #|| DEFAULT_ASSET_MODEL
      end
    end
  end
end