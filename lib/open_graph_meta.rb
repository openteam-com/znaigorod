# encoding: utf-8

module OpenGraphMeta
  extend ActiveSupport::Concern

  def open_graph_meta_tags
    []
  end

  def object_url
    h.polymorphic_url(model)
  end

  def object_image
    h.resized_image_url(poster_url, 180, 242)
  end

  def meta_keywords
    [kind.map(&:text).join(', '), open_graph_meta_tags].compact.flatten.map(&:mb_chars).map(&:downcase).join(', ')
  end

  def html_description
    @html_description ||= description.to_s.as_html.without_table.gsub(/<\/?\w+.*?>/m, '').gsub(' ,', ',').squish.html_safe
  end

  def page_og_description
    @page_og_description ||= og_description if model.has_attribute?(:og_description)
  end

  def page_og_title
    @page_og_title ||= og_title if model.has_attribute?(:og_title)
  end

  def meta_description(lendth = 160)
    page_og_description || html_description.truncate(lendth, :separator => ' ').html_safe
  end

  def open_graph_meta
    res = ""
    res << "<meta property='og:description' content='#{meta_description(300)}'/>\n"
    res << "<meta property='og:site_name' content='#{I18n.t('meta.' + "#{Settings['app.city']}" + '.default.title')}' />\n"
    res << "<meta property='og:title' content='#{page_og_title || model.title}' />\n"
    res << "<meta property='og:url' content='#{object_url}' />\n"
    res << "<meta property='og:image' content='#{object_image}' />\n"
    res << "<link rel='image_src' href='#{object_image}' />\n"
    res.html_safe
  end

  def twitter_cards_meta
    res = ""
    res << "<meta name='twitter:card' content='summary' />\n"
    res << "<meta name='twitter:site' content='@znaigorod' />\n"
    res << "<meta name='twitter:url' content='#{object_url}' />\n"
    res << "<meta name='twitter:title' content='#{model.title}' />\n"
    res << "<meta name='twitter:description' content='#{meta_description(140)}' />\n"
    res << "<meta name='twitter:image' content='#{object_image}' />\n"
    res.html_safe
  end
end
