class AddUserIdToMapPlacemarks < ActiveRecord::Migration
  def change
    add_column :map_placemarks, :user_id, :integer
  end
end
