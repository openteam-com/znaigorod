# encoding: utf-8

class Version < ActiveRecord::Base
  extend HTMLDiff

  attr_accessible :body
  serialize :body, JSON

  belongs_to :versionable, :polymorphic => true

  def what_changed
    body
  end

  def self.count_for(name)
    where(:versionable_type => name).pluck('versionable_id').uniq.count
  end
end

# == Schema Information
#
# Table name: versions
#
#  id               :integer          not null, primary key
#  body             :text
#  versionable_id   :integer
#  versionable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

