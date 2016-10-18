class FullSchedule < ActiveRecord::Base
   attr_accessible :monday, :tuesday, :breaks_attributes, :wednesday, :thursday, :friday, :saturday, :sunday, :from, :to, :free
   has_many :breaks
   belongs_to :schedulable, polymorphic: true, foreign_type: :schedulable_type, foreign_key: :schedulable_id
   accepts_nested_attributes_for :breaks, :reject_if => :all_blank, :allow_destroy => true
end
