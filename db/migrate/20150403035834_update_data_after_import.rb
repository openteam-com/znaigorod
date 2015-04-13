class UpdateDataAfterImport < ActiveRecord::Migration
  def up
    Address.all.each do |address|
      address.update_column :latitude, address.latitude.gsub(',', '.') if address.latitude?
      address.update_column :longitude, address.longitude.gsub(',', '.') if address.longitude?
    end

    OrganizationCategory.find_each do |oc|
      oc.save
    end

    YAML.load_file('/home/koala/Загрузки/slugs.yml').each do |key, value|
      OrganizationCategory.find(value).update_attribute(:slug, key)
    end
  end

  def down
  end
end
