class AddPublishedToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :published, :boolean, :default => false

    Organization.update_all :published => true if Organization.count > 0
  end
end
