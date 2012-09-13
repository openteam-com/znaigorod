class OrganizationsCollection
  include ActiveAttr::MassAssignment
  include Rails.application.routes.url_helpers

  attr_accessor :organization_class, :category, :query

  def initialize(params)
    super(params)
    @organization_class ||= 'organizations'
    @organization_class = @organization_class.singularize
    @category ||= 'all'
    @category = @category.mb_chars.downcase
  end

  def self.kinds
    [Meal, Entertainment, Culture]
  end

  self.kinds.map(&:name).map(&:downcase).each do |klass|
    define_method "#{klass}_searcher" do
      HasSearcher.searcher(klass.to_sym)
    end

    define_method "#{klass}_categories_links" do
      self.send("#{klass}_categories").map do |row|
        Link.new(title: "#{row.value} (#{row.count})", url: organizations_path(organization_class: klass.pluralize, category: row.value.mb_chars.downcase))
      end
    end

    define_method "#{klass}_categories" do
      self.send("#{klass}_searcher").categories.facet("#{klass}_category").rows
    end
  end

  def kind_links
    {}.tap do |links|
      self.class.kinds.map(&:name).map(&:downcase).each do |klass|
        links[Link.new(title: I18n.t("organization.kind.#{klass}"), url: organizations_path(organization_class: klass.pluralize))] = self.send("#{klass}_categories_links")
      end
    end
  end

  def class_categories_links
    [Link.new(title: I18n.t("organization.all.#{organization_class}"), url: organizations_path(organization_class: organization_class.pluralize), current: category == 'all')].tap do |links|
      self.send("#{organization_class}_categories").each do |row|
        link_kind = row.value.mb_chars.downcase
        links << Link.new(title: "#{row.value} (#{row.count})", url: organizations_path(organization_class: organization_class.pluralize, category: link_kind), current: category == link_kind)
      end
      current_index = links.index { |link| link.current? }
      links[current_index - 1].html_options[:class] = :before_current if current_index > 0
      links[current_index + 1].html_options[:class] = :after_current if current_index < links.size - 1
      links[current_index].html_options[:class] = :current
    end
  end

  def title
    I18n.t("organization.list_title.#{organization_class}")
  end

  def subtitle
    return "" if category == 'all'
    category
  end

  def view
    return 'catalog' if organization_class == 'organization'
    'index'
  end

end
