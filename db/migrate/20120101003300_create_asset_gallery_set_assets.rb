class CreateAssetGallerySetAssets < ActiveRecord::Migration
  def change
    create_table :asset_gallery_set_assets do |t|
      t.belongs_to :set, :null => false
      t.integer :asset_id, :position, :null => false
      t.string :caption
      t.timestamps
    end
  end
end
