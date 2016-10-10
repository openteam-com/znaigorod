class CreateBrandForContents < ActiveRecord::Migration
  def change
    create_table :brand_for_contents do |t|
      t.string       :content_type
      t.integer      :content_id
      t.attachment   :background
      t.string       :color

      t.timestamps
    end
    add_index :brand_for_contents, :content_id
    add_index :brand_for_contents, :content_type
  end
end
