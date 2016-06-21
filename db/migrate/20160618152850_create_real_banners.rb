class CreateRealBanners < ActiveRecord::Migration
  def change
    create_table :real_banners do |t|
      t.string :title
      t.string :url
      t.attachment :image
      t.integer :height
      t.integer :width
      t.string :place
      t.datetime :show_time
      t.boolean :show
      t.timestamps
    end
  end
end
