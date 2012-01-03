module AssetGallery
  class SetAsset < ActiveRecord::Base
    belongs_to :set
    
    @@loaded = false
    
    validate :asset_id, :presence => true
    validate :position, :presence => true
    
    #----------
    
    def asset 
      if @_asset
        return @_asset
      end
      
      key = "asset_gallery/asset:#{self.asset_id}"
      
      if @@loaded && a = Rails.cache.read(key)
        @_asset = a
        return @_asset
      else
        # load
        @_asset = AssethostAsset.find self.asset_id

        # write cache that can be expired by content or asset
        Rails.cache.write(key,@_asset,:objects => [self.set,@_asset])

        @@loaded = true

        return @_asset
      end
    end
    
    #----------
    
    # Fetch asset JSON and then merge in our caption and position
    def as_json(options)
      # grab asset as_json, merge in our values, then call to_json on that
      self.asset.as_json(options).merge({"caption" => self.caption, "ORDER" => self.position})
    end
  end
end
