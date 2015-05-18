# encoding: utf-8

class ReviewDecorator < ApplicationDecorator
  decorates :review

  include OpenGraphMeta

  delegate :title, :to => :review

  def truncated_title(length, separator = ' ')
    title.length > length ?
      title.text_gilensize.truncated(length, separator) :
      title.text_gilensize
  end

  def truncated_title_link(length, options = { separator: ' ', anchor: nil })
    title.length > length ?
      h.link_to(truncated_title(length, options[:separator]), h.review_path(review, anchor: options[:anchor]), :title => title) :
      h.link_to(title.text_gilensize, h.review_path(review, anchor: options[:anchor]))
  end

  def has_annotation_image?
    true if review.poster_url? || review.poster_image_url? || review.gallery_images.any? || review.gallery_social_images.any?
  end

  def annotation_image(width, height)
    if review.poster_url?
      h.resized_image_url(review.poster_url, width, height)
    elsif review.poster_image_url?
      h.resized_image_url(review.poster_image_url, width, height)
    elsif review.gallery_images.any?
      h.resized_image_url(review.gallery_images.first.file_url, width, height)
    elsif review.gallery_social_images.any?
      review.gallery_social_images.first.file.url
    else
      'public/post_poster_stub.jpg'
    end
  end

  def show_url
    h.review_url(review)
  end

  def date
    date = review.created_at || Time.zone.now

    h.content_tag :div, I18n.l(date, :format => "%d %B %Y"), :class => :date
  end

  def likes_count
    votes.liked.size
  end

  def related_reviews
    similar_ids = similar.map(&:id)
    @related_reviews = relations.where(slave_type: 'Review').delete_if { |review| review.slave && similar_ids.include?(review.slave.id) }
  end

  def related_afishas
    @related_afishas = relations.where(slave_type: 'Afisha').delete_if { |afisha| afisha.slave.blank? || !afisha.slave.actual? }
  end

  def related_discounts
    @related_discounts = relations.where(slave_type: 'Discount').delete_if { |discount| discount.slave.blank? || !discount.slave.actual? }
  end

  def related_organizations
    @related_organizations = relations.where(slave_type: 'Organization')
  end

  def related_photogalleries
    @related_photogalleries = relations.where(slave_type: 'Photogallery')
  end

  def tags
    tag.split(',').map(&:squish).map(&:mb_chars).map(&:downcase)
  end

  def content_for_index
    @content_for_index ||= cached_content_for_index
  end

  def content_for_show
    @content_for_show ||= (URI.unescape(cached_content_for_show.force_encoding('ASCII-8BIT')).force_encoding('utf-8')).try(:html_safe)
  end

  def raw_content_for_show
    @raw_content_for_show ||= is_a?(ReviewVideo) ?
      AutoHtmlRenderer.new(video_url).render_show + AutoHtmlRenderer.new(content, allow_external_links: allow_external_links).render_show :
      AutoHtmlRenderer.new(content, allow_external_links: allow_external_links).render_show
  end

  def html_image(image, width, height)
    "<li>#{h.link_to(h.image_tag(h.resized_image_url(image.file_url, width, height), :size => '#{width}x#{height}', :alt => review.title, :title => review.title), h.review_path(review), :title => review.title)}</li>"
  end

  def html_social_image(image, width, height)
    "<li>#{h.link_to(h.vk_image_tag(image, width, height), h.review_path(review), :title => review.title, :style => "display: block; width: #{width}px; height: #{height}px; position: relative; overflow: hidden;")}</li>"
  end

  def annotation_gallery(width = 234, height = 158)
    gallery = ''

    review.all_images.limit(6).each_with_index do |image, index|
      if image.is_a?(GalleryImage)
        index == 0 ? gallery << html_image(image, width, height) : gallery << html_image(image, width/2 - 1, height/2 - 1)
      else
        index == 0 ? gallery << html_social_image(image, width, height) : gallery << html_social_image(image, width/2 - 1, height/2 - 1)
      end
    end

    gallery.html_safe
  end

  def has_annotation_gallery?
    (gallery_images.count + gallery_social_images.count) > 5
  end

  def images
    all_images
  end

  def searcher_params
    @searcher_params ||= {}.tap do |params|
      params[:type] = 'question' if review.is_a?(Question)
    end
  end

  def similar
    @similar ||= begin
                   searcher = HasSearcher.searcher(:reviews, searcher_params).paginate(:page => 1, :per_page => 3).more_like_this(review)
                   searcher.without_eighteen_plus unless review.eighteen_plus?

                   searcher.results
                 end
  end

  def decorated_similar
    @decorated_similar ||= ReviewDecorator.decorate(similar)
  end

  # overrides OpenGraphMeta.meta_keywords
  def meta_keywords
    [categories.map(&:text).join(', '), open_graph_meta_tags].compact.flatten.map(&:mb_chars).map(&:downcase).join(', ')
  end

  # overrides OpenGraphMeta.open_graph_meta_tags
  def open_graph_meta_tags
    @open_graph_meta_tags ||= tags if tag?
  end

  # overrides OpenGraphMeta.html_description
  def html_description
    @html_description ||= content.to_s.as_html.without_table.gsub(/<\/?\w+.*?>/m, '').gsub(' ,', ',').squish.html_safe
  end

  # overrides OpenGraphMeta.object_url
  def object_url
    h.review_url(review)
  end

  # overrides OpenGraphMeta.object_image
  def object_image
    annotation_image(242, 180)
  end
end
