class AddStateToMapPlacemarks < ActiveRecord::Migration
  def change
    add_column :map_placemarks, :state, :string

    MapPlacemark.update_all(:state => 'published') if MapPlacemark.any?
  end
end
