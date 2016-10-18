class Break < ActiveRecord::Base
   attr_accessible :from, :to
   belongs_to :full_schedule
end
