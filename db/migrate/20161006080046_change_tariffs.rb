class ChangeTariffs < ActiveRecord::Migration
  def change
    remove_column :tariffs, :attachment_files
    remove_column :tariffs, :tour3d
    add_column :tariffs, :small_comment, :boolean
    add_column :tariffs, :price_list, :boolean
    add_column :tariffs, :brand, :boolean
  end
end
