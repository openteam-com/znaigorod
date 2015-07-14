# encoding: utf-8

class AfishaObserver < ActiveRecord::Observer
  def after_to_published(afisha, transition)
    if afisha.user.present?
      if !afisha.user.roles.any? && afisha.user.email.present?
        MyMailer.delay(:queue => 'mailer').mail_new_published_afisha(afisha)
      end
      Feed.create(
        :feedable => afisha,
        :account => afisha.user.account,
        :created_at => afisha.created_at,
        :updated_at => afisha.updated_at
      )
    end
  end

  def after_to_draft(afisha, transition)
    afisha.reindex_showings

    if afisha.user.present?
      NotificationMessage.delay(:queue => 'critical').create(
        account: afisha.user.account,
        kind: :afisha_returned,
        messageable: afisha) unless afisha.user.is_admin?
    end
  end

  def before_save(afisha)
    if afisha.published? && afisha.change_versionable? && !afisha.user.roles.any?
      afisha.save_version
      MyMailer.delay(:queue => 'mailer', :retry => false).send_afisha_diff(afisha.versions.last) if afisha.versions.last.present?
    end
  end

  def after_save(afisha)
    placemark = afisha.relations.where(master_type: 'MapPlacemark').first.try(:master)
    if placemark.is_a? MapPlacemark
      placemark.title = afisha.title
      placemark.latitude = afisha.organization.try(:latitude) || afisha.showings.first.latitude
      placemark.longitude = afisha.organization.try(:longitude) || afisha.showings.first.longitude
      #placemark.latitude = afisha.organization.latitude
      #placemark.longitude = afisha.organization.longitude
      placemark.image_url = resized_image_url(afisha.poster_url, 190, 260, { :magnify => nil, :orientation => nil })
      placemark.when = AfishaDecorator.new(afisha).human_when
      placemark.save
    end

    return unless afisha.published?

    #afisha.delay(:queue => 'critical').reindex_showings
    afisha.reindex_showings

    afisha.delay(:queue => 'critical').upload_poster_to_vk if (afisha.poster_vk_id.nil? || afisha.poster_url_changed?) && afisha.poster_url?
  end
end
