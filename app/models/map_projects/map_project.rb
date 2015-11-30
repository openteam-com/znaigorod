class MapProject < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  attr_accessible :title, :related_items, :need_change, :cluster_icon, :slug
  attr_accessor :related_items, :need_change

  validates_presence_of :title

  has_many :map_layers,                                    dependent: :destroy
  has_many :relations,             as: :master,            dependent: :destroy
  has_many :reviews,        :through => :relations, :source => :slave, :source_type => Review

  has_attached_file :cluster_icon, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  after_save :parse_related_items

  def should_generate_new_friendly_id?
    return true if !self.slug?

    false
  end

  def parse_related_items
    relations.destroy_all if related_items.nil?
    return true unless related_items
    relations.destroy_all

    related_items.each do |item|
      slave_type, slave_id = item.split("_")

      relation = relations.new
      relation.slave_type = slave_type.classify
      relation.slave_id = slave_id

      relation.save
    end
  end
end

# == Schema Information
#
# Table name: map_projects
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  slug                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cluster_icon_url          :string(255)
#  cluster_icon_file_name    :string(255)
#  cluster_icon_content_type :string(255)
#  cluster_icon_file_size    :string(255)
#  amount                    :integer          default(300)
#

