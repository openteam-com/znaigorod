class OrganizationCategory < ActiveRecord::Base
  extend FriendlyId

  alias_attribute :to_s, :title
  attr_accessible :title, :parent

  default_scope order('title')

  has_many :organization_category_items, :dependent => :destroy

  has_many :review_category_items, :dependent => :destroy
  has_many :reviews, :through => :review_category_items

  has_many :features, :dependent => :destroy

  validates :title, presence: true, uniqueness: { scope: :ancestry }

  friendly_id :title, :use => :slugged

  has_ancestry

  def self.used_roots
    OrganizationCategory.roots.where('title NOT IN (?)', ['Автосервис', 'Туристические агентства','Магазины'])
  end

  def should_generate_new_friendly_id?
    slug? ? false : true
  end

  def organizations
    Organization.joins(:organization_categories).where(:organization_categories => { :id => subtree_ids }).uniq
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

