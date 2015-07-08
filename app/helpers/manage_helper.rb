# encoding: utf-8
module ManageHelper
  def form_url_for_resource
    if resource_class == Afisha || resource_class == Organization
      [:manage, resource]
    elsif Organization.available_suborganization_classes.include?(resource_class)
      send("manage_organization_#{resource_class.model_name.underscore}_path", parent)
    elsif resource.is_a?(GalleryImage) && Organization.available_suborganization_classes.include?(parent_class)
      [:manage, parent, resource]
    elsif parent.class == Afisha
      if (resource_class == GalleryImage || resource_class == GallerySocialImage || resource_class == GalleryFile) && resource.persisted?
        send("manage_#{parent.class.model_name.underscore}_#{resource_class.model_name.underscore}_path", parent, resource)
      elsif resource_class == Ticket
        send("manage_statistics_#{parent.class.model_name.underscore}_#{resource_class.model_name.underscore.pluralize}_path", parent)
      else
        send("manage_#{parent.class.model_name.underscore}_#{resource_class.model_name.underscore.pluralize}_path", parent)
      end
    elsif parent.class == Organization
      if (resource_class == GalleryImage || resource_class == GalleryFile) && resource.persisted?
        send("manage_organization_#{resource_class.model_name.underscore}_path", parent, resource)
      else
        send("manage_organization_#{resource_class.model_name.underscore.pluralize}_path", parent)
      end
    elsif parent.class == SaunaHall
      if resource_class == GalleryImage && resource.persisted?
        [:manage, @organization, @sauna_hall, :gallery_image]
      else
        [:manage, @organization, @sauna_hall, :gallery_image]
      end
    elsif resource_class == SaunaHall
      if resource.new_record?
        manage_organization_sauna_sauna_halls_path(@organization)
      else
        manage_organization_sauna_sauna_hall_path(@organization, @sauna_hall)
      end
    elsif resource_class == PoolTable
      if resource.new_record?
        manage_organization_billiard_pool_tables_path(@organization)
      else
        manage_organization_billiard_pool_table_path(@organization, @pool_table)
      end
    end
  end

  def date_info_for_place_item(place_item)
    content = 'с '
    content << l(place_item.starts_at)
    content << ' по '
    content << l(place_item.ends_at)
    content << " (#{time_ago_to_close(place_item)})"
    content.html_safe
  end

  def time_ago_to_close(place_item)
    if Time.zone.now > place_item.ends_at
      "<span class='warn'>закончилось #{time_ago_in_words place_item.ends_at} назад</span>".html_safe
    else
      "<span class='norm'>осталось #{time_ago_in_words place_item.ends_at}</span>".html_safe
    end
  end

  def primary_organization
    begin
      Organization.find(params[:organization_id]).id
    rescue => e
      nil
    end
  end
end
