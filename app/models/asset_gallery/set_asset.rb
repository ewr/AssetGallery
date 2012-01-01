module AssetGallery
  class SetAsset < ActiveRecord::Base
    belongs_to :set
    
    validate :asset_id, :presence => true
    validate :position, :presence => true
  end
end
