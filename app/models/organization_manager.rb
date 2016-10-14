class OrganizationManager < ActiveRecord::Base
   attr_accessible :organization_id, :user_id
   belongs_to :organization
   belongs_to :manager, class_name: 'User', foreign_key: :user_id
end
