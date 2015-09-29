class ReviewsPresenter
  include ActiveAttr::MassAssignment

  class Parameters
    include Rails.application.routes.url_helpers
    include Singleton

    attr_accessor :type, :category, :order_by, :only_tomsk

    def params
      { :type => type, :category => category, :order_by => order_by, :only_tomsk => only_tomsk }
    end

    def path(type: self.type, category: self.category, order_by: self.order_by, only_tomsk: self.only_tomsk)
      return reviews_path(:order_by => order_by, :only_tomsk => only_tomsk) if type.blank? && category.blank?

      path = [type, category].compact.join('_')

      send "reviews_#{path}_path", :order_by => order_by, :only_tomsk => only_tomsk
    end
  end

  class Counter
    def initialize(args)
      @args = args
    end

    def count
      HasSearcher.searcher(:reviews, @args).without_questions.total_count
    end
  end

  class TypeFilter
    attr_accessor :type

    def initialize
      @type = Parameters.instance.type
    end

    def available
      { nil => 'Все', 'article' => 'Обзоры', 'photo' => 'Фотообзоры', 'video' => 'Видеообзоры' }
    end

    def selected
      available.keys.compact.include?(type) ? type : available.keys.first
    end

    def links
      [all_link] + type_links
    end

    private

    def all_link
      Hashie::Mash.new(
        :title => 'Все',
        :klass => ''.tap { |s| s << ' selected' if nil == selected },
        :path => Parameters.instance.path(type: nil, category: nil)
      )
    end

    def type_links
      available.except(nil).map do |value, title|
        Hashie::Mash.new(
          :title => title,
          :klass => value.dup.tap { |s| s << ' selected' if value == selected },
          :path => Parameters.instance.path(type: value)
        )
      end
    end
  end

  class CategoryFilter
    attr_accessor :category

    alias :selected :category

    def initialize
      @category = Parameters.instance.category
    end

    def available
      @available ||= HasSearcher.searcher(:reviews).facet(:category).rows.map(&:value)
    end

    def links
      @links ||= [all_link] + category_links
    end

    def more?
      return false if selected.blank?

      available.index(selected).to_i > 6
    end

    %w(eighteen_plus megapolis inform adv_plus).each do |item|
      define_method "#{item}?" do
        selected == item
      end
    end

    def human_titles
      Hash[Review.categories.options].invert
    end

    def all_link
      params = Parameters.instance.params.merge(:category => nil)

      Hashie::Mash.new(
        :value => nil,
        :title => params[:type]? I18n.t("activerecord.models.review.#{params[:type]}") : 'Все обзоры',
        :klass => "all #{params[:type]}".tap { |s| s << ' selected' if category.blank? },
        :path => Parameters.instance.path(category: nil),
        :results_count => Counter.new(params).count
      )
    end

    def category_links
      available.map do |category|
        params = Parameters.instance.params.merge(:category => category)
        title = human_titles[category]

        Hashie::Mash.new(
          :value => category,
          :title => title,
          :klass => category.dup.tap { |s| s << ' selected' if category == selected },
          :path => Parameters.instance.path(category: category),
          :results_count => Counter.new(params).count
        )
      end
    end
  end

  class OrderByFilter
    attr_accessor :order_by

    def initialize
      @order_by = Parameters.instance.order_by
    end

    def available
      { 'creation' => 'Новизне', 'rating' => 'Рейтингу', 'commented' => 'Количеству комментариев' }
    end

    def selected
      available.keys.compact.include?(order_by) ? order_by : available.keys.first
    end

    def random?
      order_by == 'random'
    end

    def links
      available.map do |value, title|
        Hashie::Mash.new(
          :value => value,
          :title => title,
          :klass => "#{value}".tap { |s| s << ' selected' if value == selected },
          :path => Parameters.instance.path(order_by: value),
        )
      end
    end
  end

  class OnlyTomskFilter
    attr_accessor :only_tomsk

    def initialize
      @only_tomsk = Parameters.instance.only_tomsk
    end

    def selected?
      only_tomsk
    end

    def value_for_path
      selected? ? nil : true
    end

    def link
      Hashie::Mash.new(
        :title => "Только #{Settings['app.city_ru']}",
        :klass => selected? ? 'only-tomsk selected': 'only-tomsk',
        :path => Parameters.instance.path(only_tomsk: value_for_path)
      )
    end
  end

  attr_accessor :type, :category,
                :order_by, :page, :per_page,
                :only_tomsk

  attr_reader :type_filter, :category_filter, :order_by_filter, :only_tomsk_filter

  def initialize(args)
    super(args)

    normalize_args
    store_parameters
    initialize_filters
  end

  def collection
    searcher.results
  end

  def total_count
    searcher.total_count
  end

  def current_count
    total_count.to_i - (@page.to_i * @per_page.to_i)
  end

  def decorated_collection
    @decorated_collection ||= ReviewDecorator.decorate(collection)
  end

  def page_title
    searcher_params[:category].present? ? I18n.t("meta.#{Settings['app.city']}.reviews.#{searcher_params[:category]}.title") : I18n.t("meta.#{Settings['app.city']}.reviews.title")
  end

  def meta_description
    I18n.t("meta.#{Settings['app.city']}.reviews.description", default: '')
  end

  def meta_keywords
    I18n.t("meta.#{Settings['app.city']}.reviews.keywords", default: '')
  end

  private

  def normalize_args
    @page     ||= 1
    @per_page ||= per_page.to_i.zero? ? 12 : per_page.to_i
    @only_tomsk ||= @only_tomsk.present? ? true : nil
  end

  def store_parameters
    %w(type category order_by only_tomsk).each { |p| Parameters.instance.send "#{p}=", send(p) }
  end

  def initialize_filters
    @type_filter       ||= TypeFilter.new
    @category_filter   ||= CategoryFilter.new
    @order_by_filter   ||= OrderByFilter.new
    @only_tomsk_filter ||= OnlyTomskFilter.new
  end


  def searcher_params
    @searcher_params ||= {}.tap do |params|
      params[:type]             = type_filter.selected
      params[:category]         = category_filter.selected
    end
  end

  def searcher
    @searcher ||= HasSearcher.searcher(:reviews, searcher_params).tap { |s|
      order_by_filter.random? ? s.order_by(:random) : s.send("order_by_#{order_by_filter.selected}")

      s.without_questions
      s.without_megapolis             unless category_filter.megapolis?
      s.without_inform                unless category_filter.inform?
      s.without_eighteen_plus         unless category_filter.eighteen_plus?
      s.without_adv_plus              unless category_filter.adv_plus?
      s.only_tomsk                    if     only_tomsk_filter.selected?

      s.paginate page: page, per_page: per_page
    }
  end
end
