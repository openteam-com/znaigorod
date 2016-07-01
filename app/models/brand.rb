class Brand < ActiveRecord::Base
  attr_accessible :background, :title, :url, :time_from, :time_to, :show
  has_attached_file :background, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validates_presence_of :background, :title, :url, :time_from, :time_to

  def self.is_actual?
    return false unless Brand.first.present?
    return first.show || DateTime.now.between?(first.time_from, first.time_to) ? true : false
  end
end
