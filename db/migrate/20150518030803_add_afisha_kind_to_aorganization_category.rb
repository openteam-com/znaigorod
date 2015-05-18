class AddAfishaKindToAorganizationCategory < ActiveRecord::Migration
  def change
    add_column :organization_categories, :afisha_kind, :text
  end
end
