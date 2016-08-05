class AddColumnsToTariff < ActiveRecord::Migration
  def change
    add_column :tariffs, :logotype, :boolean, :default => false
    add_column :tariffs, :tour3d, :boolean, :default => false
    add_column :tariffs, :gallery, :boolean, :default => false
    add_column :tariffs, :description_field, :boolean, :default => false
    add_column :tariffs, :attachment_files, :boolean, :default => false
  end
end
