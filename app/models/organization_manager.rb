class OrganizationManager < ActiveRecord::Base
   attr_accessible :organization_id, :user_id, :email, :status, :user_name
   attr_accessor :user_id_temp
   validates_presence_of :organization_id
   belongs_to :organization
   belongs_to :manager, class_name: 'User', foreign_key: :user_id
end
