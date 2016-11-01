# encoding: utf-8
module OrganizationHelper
  def actual_discounts?(org)
    Discount.where(id: org.try(:discounts).try(:map, &:id)).actual.present?
  end

  def logotype_url(org)
    org.primary_organization.try(:poster_url) || org.poster_url
  end

  def organization_sauna(org)
    org.primary_organization.try(:sauna) || org.sauna
  end

  def organization_hotel(org)
    org.primary_organization.try(:hotel) || org.hotel
  end

  def status(org)
    (org.primary_organization.try(:status) || org.status).split('_').first
  end

  def icon_width(org)
    org.show_custom_balloon_icon || org.primary_organization.try(:show_custom_balloon_icon) ? 70 : 35
  end

  def icon_height(org)
    org.show_custom_balloon_icon || org.primary_organization.try(:show_custom_balloon_icon) ? 70 : 50
  end
end
