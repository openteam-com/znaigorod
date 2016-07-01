class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :title
      t.boolean :show
      t.datetime :time_from
      t.datetime :time_to
      t.attachment :background
      t.string :url
      t.timestamps
    end
  end
end
