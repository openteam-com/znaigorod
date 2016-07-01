class CreateBrandRecord < ActiveRecord::Migration
  def up
    Brand.create(:time_from=>Time.zone.now, :time_to=>Time.zone.now)
  end

  def down
  end
end
