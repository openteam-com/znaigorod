class UpdateDataAfterImport < ActiveRecord::Migration
  def up
    Address.all.each do |address|
      address.update_column :latitude, address.latitude.gsub(',', '.') if address.latitude?
      address.update_column :longitude, address.longitude.gsub(',', '.') if address.longitude?
    end

    OrganizationCategory.find_each do |oc|
      oc.save
    end
  end

  def down
  end
end
