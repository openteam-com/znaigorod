class AddTagToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :tag, :string
  end
end
