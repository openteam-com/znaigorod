class AddManagerIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :manager_id, :integer
    Organization.all.each do |org|
      unless org.user_id.nil?
        org.update_attribute(:manager_id, org.user_id)
        org.update_attribute(:user_id, nil)
      end
    end
  end
end
