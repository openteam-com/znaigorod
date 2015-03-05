class OrganizationCategory < ActiveRecord::Base
  alias_attribute :to_s, :title
  attr_accessible :title, :parent

  default_scope order('title')

  has_many :organization_category_items, :dependent => :destroy
  has_many :organizations, :through => :organization_category_items

  has_many :review_category_items, :dependent => :destroy
  has_many :reviews, :through => :review_category_items

  validates :title, presence: true, uniqueness: { scope: :ancestry }

  has_ancestry

  def self.used_roots
    OrganizationCategory.roots.where('title NOT IN (?)', ['Автосервис', 'Туристические агентства','Магазины'])
  end

  def downcased_title
    title.mb_chars.downcase.to_s
  end

  def available_kinds
    I18n.t('organization.kind').invert.inject({}) { |h, (k, v)| h[k.mb_chars.downcase.to_s] = v.to_s; h }
  end

  def kind
    parent ? available_kinds[parent.downcased_title] : available_kinds[downcased_title]
  end

  def organizations_count
    facet_row = Organization.search { facet :organization_category, :only => downcased_title }.facet(:organization_category).rows.first

    facet_row ? facet_row.count : 0
  end

  #def organizations
    #Organization.search { with :organization_category, downcased_title; paginate :page => 1, :per_page => 1_000_000 }.results
  #end

  def category_path_string
    return 'car_washes_avtomoykis_path' if downcased_title == 'автомойки'
    return 'saunas_path' if downcased_title == 'сауны'

    "#{kind.pluralize}_#{downcased_title.from_russian_to_param.pluralize}_path"
  end
end

# == Schema Information
#
# Table name: organization_categories
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

