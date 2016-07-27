class MakeTheirOrganizationRequest < ActiveRecord::Base
   attr_accessible :phone, :email, :user_id, :organization_id
   belongs_to :user
   belongs_to :organization
end
