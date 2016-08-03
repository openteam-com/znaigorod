class AddDurationAndTariffIdToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :duration, :string
    add_column :payments, :tariff_id, :integer
  end
end
