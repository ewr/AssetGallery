module AssetGallery
  class SetAsset < ActiveRecord::Base
    belongs_to :set
    
    puts "setting asset association to #{AssetGallery::Config.asset_model}"
    belongs_to :asset, :class_name => AssetGallery::Config.asset_model
    
    @@loaded = false
    
    validate :asset_id, :presence => true
    validate :position, :presence => true
    
    #----------
    
    # Fetch asset JSON and then merge in our caption and position
    def as_json(options={})
      # grab asset as_json, merge in our values, then call to_json on that
      self.asset.as_json(options).merge({"caption" => self.caption, "ORDER" => self.position})
    end
  end
end
