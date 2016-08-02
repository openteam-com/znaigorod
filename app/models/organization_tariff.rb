class OrganizationTariff < ActiveRecord::Base
  attr_accessible :organization_id, :tariff_id, :duration, :price

  belongs_to :organization
  belongs_to :tariff
end


