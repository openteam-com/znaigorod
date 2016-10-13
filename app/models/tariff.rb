class Tariff < ActiveRecord::Base
  attr_accessible :title, :description, :price_for_month,
                  :price_for_six_months, :price_for_year,
                  :tag, :logotype, :small_comment, :description_field,
                  :price_list, :gallery, :brand
  validates_presence_of :title, :description, :tag, :price_for_month, :price_for_six_months, :price_for_year

  scope :minimal, -> { where(:tag => :min) }
  scope :middle,  -> { where(:tag => :base) }
  scope :premium, -> { where(:tag => :full) }

  extend Enumerize
  enumerize :tag, :in => [:min, :base, :full], :default => :min
  has_many :organization_tariffs
  has_many :organizations, :through => :organization_tariffs
end
