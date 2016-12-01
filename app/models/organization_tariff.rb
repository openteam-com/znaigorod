class OrganizationTariff < ActiveRecord::Base
  attr_accessible :organization_id, :tariff_id, :duration, :price

  belongs_to :organization
  belongs_to :tariff

  def left_days
    ((created_at + duration.to_i.months - Time.now)/60/60/24).to_i
  end
end


