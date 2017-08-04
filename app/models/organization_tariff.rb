class OrganizationTariff < ActiveRecord::Base
  attr_accessible :organization_id, :tariff_id, :duration, :price

  belongs_to :organization
  belongs_to :tariff

  def duration_convert
    case duration
    when 'month'
      1.month
    when 'six_months'
      6.months
    when 'year'
      1.year
    end.to_i
  end

  def left_days
    ((created_at + duration_convert - Time.now)/60/60/24).to_i
  end
end


