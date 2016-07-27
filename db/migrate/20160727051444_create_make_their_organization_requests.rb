class CreateMakeTheirOrganizationRequests < ActiveRecord::Migration
  def change
    create_table :make_their_organization_requests do |t|
      t.belongs_to :user
      t.belongs_to :organization
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
