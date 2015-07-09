class HitDecorator < ApplicationDecorator
  decorates 'sunspot/search/hit'

  AFFICHE_FIELDS = %w[tag]
  ORGANIZATION_FIELDS = %w[category cuisine feature offer payment]
  ADDITIONAL_FIELDS = AFFICHE_FIELDS + ORGANIZATION_FIELDS

  def result_decorator
    @decorator ||=
      if organization?
        OrganizationDecorator.new(result)
      elsif afisha?
        AfishaDecorator.new(result)
      elsif account?
        AccountDecorator.new(result)
      elsif question?
        QuestionDecorator.new(result)
      elsif review?
        ReviewDecorator.new(result)
      elsif discount?
        DiscountDecorator.new(result)
      end
  end

  %w[afisha organization question review account discount].each do |name|
    define_method "#{name}?" do
      result.is_a? name.classify.constantize
    end
  end

  def show_url
    afisha? ? h.afisha_show_path(result_decorator) : result_decorator
  end

  def has_image?
    return true if organization? && result_decorator.logotype_url? && result_decorator.client?

    return true if review?
  end

  # FIXME: грязный хак
  def fake_kind
      kind = suborganization.class.name.underscore.gsub(/_decorator/, '')
    %w[billiard sauna].include?(kind) ? 'entertainment' : kind
  end

  def suborganization_categories_hash
    @suborganization_categories_hash ||= suborganization.organization.suborganizations.
      map(&:class).map(&:name).
      map { |class_name| "#{class_name.underscore.pluralize}_presenter" }.
      map(&:classify).map(&:constantize).map(&:new).map { |presenter| [presenter.pluralized_kind, presenter.categories_filter.available] }

    Hash[@suborganization_categories_hash]
  end

  # FIXME: херовый какой-то метод получился
  def kind_links
    kind = ""
    if organization?
      suborganization.categories.map(&:mb_chars).map(&:downcase).each do |category|
        hash = suborganization_categories_hash.select { |_, categories| categories.include?(category) }
        pluralized_kind = hash.keys.first
        options = pluralized_kind == 'saunas' ? {} : { categories: [category] }
        kind << h.content_tag(:li, h.link_to(category.mb_chars.capitalize, h.send("#{pluralized_kind}_path", options)))
      end
    elsif afisha?
      kind << h.content_tag(:li, h.link_to(self.human_kind, h.affiches_path('categories[]' => self.kind)))
    end
    kind.html_safe
  end

  def human_kind
    I18n.t("activerecord.models.#{kind}")
  end

  def kind
    result.class.name.downcase
  end

  def raw_suborganization
    result.priority_suborganization
  end

  def suborganization_decorator_class
    "#{raw_suborganization.class.name.underscore}_decorator".classify.constantize
  end

  def suborganization
    suborganization_decorator_class.decorate raw_suborganization
  end

  def title
    (highlighted(:title) || result.title.truncated(100)).gilensize
  end

  def excerpt
    (highlighted(:description) || (result.description || '').excerpt).gilensize
  end

  def snipped_links
    links = []
    unless organization?
      %w(photogallery trailer).each do |method|
        links << Link.new(
          title: result_decorator.navigation_title(method),
          url: result_decorator.send("kind_afisha_#{method}_path")
        ) if result_decorator.send("has_#{method}?")
      end
    end
    return "" if links.empty?
    h.content_tag :ul, links.map {|l| h.content_tag :li, l.to_s}.join("\n").html_safe, class: :snipped_links
  end

  def closest
    return "" if organization?
    h.content_tag :div, result_decorator.when_with_price, class: :when_with_price
  end

  def places
    if organization?
      link = result_decorator.address_link.html_safe
      h.content_tag(:div, h.content_tag(:span, link, class: :address), class: :places)
    else
      result_places = ""
      result_decorator.places.each do |place|
        result_places << place.place
      end
      h.content_tag :div, result_places.html_safe, class: :places
    end
  end

  def splitted_fields(field)
    res = ""
    highlighted(field).to_s.split(",").each do |piece|
      link = ""
      if organization?
        link = "/#{raw_suborganization.class.name.underscore.pluralize}/?#{field.pluralize}[]=#{piece.squish.as_text.mb_chars.downcase}"
      else
        link = h.affiches_path("#{field.pluralize}[]" => piece.squish.as_text)
      end
      res << h.content_tag(:li, h.link_to(piece.squish.html_safe, link))
    end
    res.html_safe
  end

  def to_partial_path
    'hits/hit'
  end

  def highlighted(field)
    (highlights("#{field}_translit") + highlights("#{field}_ru") + highlights(field)).map(&:formatted).map{|phrase| phrase.gsub(/\A[[:punct:][:space:]]+/, '')}.join(' ... ').html_safe.presence
  end

  def truncated(field)
    result.send(field).truncated
  end
end
