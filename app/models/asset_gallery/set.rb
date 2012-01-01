module AssetGallery
  class Set < ActiveRecord::Base
    has_many :set_assets
    validate :title, :presence => true
    
    scope :published, where(:is_published => true).order("created_at desc")
    scope :is_public, where(:is_public => true)
  end
end
