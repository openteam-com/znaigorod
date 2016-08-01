class AddManagerIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :manager_id, :integer

    Organization.reset_column_information

    Organization.all.each do |org|
      org.update_attribute(:manager_id, org.user_id)
      org.update_attribute(:user_id, nil)
    end
  end
end
