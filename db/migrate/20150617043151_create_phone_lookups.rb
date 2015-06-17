class CreatePhoneLookups < ActiveRecord::Migration
  def up
    create_table :phone_lookups do |t|
      t.references :organization

      t.timestamps
    end

    pb = ProgressBar.new(Organization.count)
    Organization.find_each do |organization|
      organization.phone_show_counter.times do
        organization.phone_lookups.create!
      end
      pb.increment!
    end

    remove_column :organizations, :phone_show_counter
  end

  def down
    drop_table :phone_lookups
  end
end
