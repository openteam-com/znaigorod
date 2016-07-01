class PlacedBanner < ActiveRecord::Base
  attr_accessible :image, :title, :url, :target, :time_from, :time_to, :place
  has_attached_file :image, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validate :presence_actual_first_banner?
  validates_presence_of :title, :url, :image, :place, :time_from, :time_to, :target

  scope :first_place, -> { where(:place => :first) }
  scope :actual, -> { select { |rb| rb if DateTime.now.between?(rb.time_from, rb.time_to) } }
  scope :second_place, -> { where(:place => :second) }

  extend Enumerize
  enumerize :place, :in => [:first, :second],
              default: :second, predicates: true
  enumerize :target, :in => ['_blank', '_self'], :default => '_blank'

  def presence_actual_first_banner?
    if PlacedBanner.first_place.actual.present? && DateTime.now.between?(time_from, time_to) && place == "first"
      errors.add(:time_from, "Уже есть актуальный баннер на первой позиции!")
    end
  end
end
