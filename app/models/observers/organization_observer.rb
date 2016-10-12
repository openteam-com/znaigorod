# encoding: utf-8

class OrganizationObserver < ActiveRecord::Observer
  cattr_accessor :disabled
  def after_save(organization)
    return if OrganizationObserver.disabled

    placemark = organization.relations.where(master_type: 'MapPlacemark').first.try(:master)
    if placemark.is_a? MapPlacemark
      placemark.title = organization.title
      placemark.latitude = organization.latitude
      placemark.longitude = organization.longitude
      placemark.image_url = resized_image_url(organization.logotype_url, 190, 260, { :magnify => nil, :orientation => nil })
      placemark.save
    end
    organization.delay(:queue => 'critical').upload_poster_to_vk if (organization.poster_vk_id.nil? || organization.logotype_url_changed?) && organization.logotype_url?
    organization.delay.update_slave_organization_statuses
    organization.delay.index_suborganizations
  end

  def before_save(organization)
    if organization.published? && organization.change_versionable?
      organization.save_version
      MyMailer.update_organization(organization).deliver
    end
  end
end
