class CreateFullSchedules < ActiveRecord::Migration
  def change
    create_table :full_schedules do |t|
      t.boolean :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :free, :default => true
      t.time :from, :to
      t.integer :schedulable_id
      t.string :schedulable_type

      t.timestamps
    end
    add_index :full_schedules, :schedulable_id
    add_index :full_schedules, :schedulable_type
  end
end
