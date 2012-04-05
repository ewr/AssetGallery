module AssetGallery
  module Config
    #DEFAULT_ASSET_MODEL = AssethostAsset
    DEFAULT_LAYOUT = "application"
    
    class << self      
      def layout(layout=nil)
        @layout = layout if layout
        @layout || DEFAULT_LAYOUT
      end
            
      def asset_model(model=nil)
        @asset_model = model if model
        @asset_model #|| DEFAULT_ASSET_MODEL
      end
    end
  end
end