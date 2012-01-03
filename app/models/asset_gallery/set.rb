module AssetGallery
  class Set < ActiveRecord::Base
    has_many :set_assets, :dependent => :destroy
    
    validate :title, :presence => true
    
    scope :published, where(:is_published => true).order("created_at desc")
    scope :is_public, where(:is_public => true)
    
    def obj_key
      "asset_gallery/set:#{self.id}"
    end
    
  end
end
