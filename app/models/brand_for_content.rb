class BrandForContent < ActiveRecord::Base
  attr_accessible :color, :background, :logotype, :url, :content_id, :content_type
  has_attached_file :background, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  has_attached_file :logotype, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  belongs_to :content, :polymorphic => true
end
