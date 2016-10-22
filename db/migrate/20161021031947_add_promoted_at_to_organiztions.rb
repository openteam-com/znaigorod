class AddPromotedAtToOrganiztions < ActiveRecord::Migration
  def change
    add_column :organizations, :promoted_at, :datetime
  end
end
