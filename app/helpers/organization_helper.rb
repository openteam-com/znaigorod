# encoding: utf-8
module OrganizationHelper
  def actual_discounts?(org)
    Discount.where(id: org.try(:discounts).try(:map, &:id)).actual.present?
  end

  def logotype_url(org)
    org.primary_organization.try(:logotype_url) || org.logotype_url
  end
end
