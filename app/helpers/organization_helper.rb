# encoding: utf-8
module OrganizationHelper
  def actual_discounts?(org)
    Discount.where(id: org.try(:discounts).try(:map, &:id)).actual.present?
  end

  def logotype_url(org)
    org.primary_organization.try(:logotype_url) || org.logotype_url
  end

  def status(org)
    (org.primary_organization.try(:status) || org.status).split('_').first
  end

  def icon_width(org)
    org.show_custom_balloon_icon ? 50 : 35
  end

  def icon_height(org)
    org.show_custom_balloon_icon ? 72 : 50
  end
end
