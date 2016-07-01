class CreateBrandRecord < ActiveRecord::Migration
  def up
    brand = Brand.new(:time_from=>Time.zone.now, :time_to=>Time.zone.now)
    brand.save(:validate => false)
  end

  def down
  end
end
