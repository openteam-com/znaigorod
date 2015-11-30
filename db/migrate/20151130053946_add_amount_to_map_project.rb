class AddAmountToMapProject < ActiveRecord::Migration
  def change
    add_column :map_projects, :amount, :integer, :default => 300

    MapProject.update_all(:amount => 300) if MapProject.any?
  end
end
