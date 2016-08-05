class Tariff < ActiveRecord::Base
  attr_accessible :title, :description, :price_for_month,
                  :price_for_six_months, :price_for_year,
                  :logotype, :tour3d, :description_field,
                  :attachment_files, :gallery
  validates_presence_of :title, :description, :price_for_month, :price_for_six_months, :price_for_year
  has_many :organization_tariffs
  has_many :organizations, :through => :organization_tariffs
end
