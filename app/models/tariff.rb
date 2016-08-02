class Tariff < ActiveRecord::Base
  attr_accessible :title, :description, :price_for_month, :price_for_six_months, :price_for_year
  validates_presence_of :title, :description, :price_for_month, :price_for_six_months, :price_for_year
end
