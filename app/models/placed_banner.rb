class PlacedBanner < ActiveRecord::Base
  attr_accessible :image, :title, :url, :target, :time_from, :time_to, :place
  has_attached_file :image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  validates_presence_of :title, :url, :image, :place

  scope :first_place, -> { where(:place => :first) }
  scope :actual, -> { select { |rb| rb if DateTime.now.between?(rb.time_from, rb.time_to) } }
  scope :second_place, -> { where(:place => :second) }

  searchable do
    text :title
    text :url
    time :updated_at
  end

  extend Enumerize
  enumerize :place, :in => [:first, :second],
              default: :second, predicates: true
  enumerize :target, :in => ['_blank', '_self'], :default => '_blank'


end
