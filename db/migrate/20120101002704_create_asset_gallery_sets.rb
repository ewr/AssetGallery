class CreateAssetGallerySets < ActiveRecord::Migration
  def change
    create_table :asset_gallery_sets do |t|
      t.string :title, :null => false
      t.text :description, :notes
      t.boolean :is_published, :default => false
      t.boolean :is_public, :default => true
      t.string :password
      t.timestamps
    end
  end
end
