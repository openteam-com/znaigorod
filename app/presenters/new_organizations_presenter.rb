class NewOrganizationsPresenter
  attr_accessor :params, :category, :view_type, :query, :features, :latitude, :longitude, :radius

  def initialize(params)
    @params = params
    @category ||= OrganizationCategory.find_by_slug(params[:slug])
    @view_type = params[:view_type] || 'list'
    @query = params[:search_query].present? ? params[:search_query] : nil
    @features = params[:features] || []
    @latitude ||= params[:latitude]
    @longitude ||= params[:longitude]
    @radius ||= params[:radius]
  end

  def categories_links
    @categories_links ||= [].tap { |array|
      array << {
        title: 'Все',
        klass: 'all',
        url: "organizations_path",
        parameters: {},
        count: Organization.count
      }

      OrganizationCategory.show_on_main_page.each do |category|
        array << {
          title: category.title,
          klass: category.slug,
          url: "organizations_by_category_path",
          parameters: {:slug => category.slug},
          count: category.organizations.count
        }
      end
    }
  end

  def promoted_clients_per_page
    @promoted_clients_per_page =  params[:promoted_clients_per_page] || 7
  end

  def page_header
    return  I18n.t("meta.#{Settings['app']['city']}.organizations.page_header", default: '') unless category
    header = I18n.t("meta.#{Settings['app']['city']}.#{category.slug}.page_header", default: '')
    header = header.blank? ? I18n.t("meta.#{Settings['app']['city']}.#{category.root.slug}.page_header", default: '') : header
    header = header.blank? ? category.root.title : header
    header
  end

  def page_title
    return  I18n.t("meta.#{Settings['app']['city']}.organizations.page_title", default: '') unless category
    header = I18n.t("meta.#{Settings['app']['city']}.#{category.slug}.page_title", default: '')
    header = header.blank? ? I18n.t("meta.#{Settings['app']['city']}.#{category.root.slug}.page_title", default: '') : header
    header = header.blank? ? category.root.title : header
    header
  end

  def meta_keywords
    return  I18n.t("meta.#{Settings['app']['city']}.organizations.keywords", default: '') unless category
    header = I18n.t("meta.#{Settings['app']['city']}.#{category.slug}.keywords", default: '')
    header = header.blank? ? I18n.t("meta.#{Settings['app']['city']}.#{category.root.slug}.keywords", default: '') : header
    header
  end

  def meta_description
    return  I18n.t("meta.#{Settings['app']['city']}.organizations.description", default: '') unless category
    header = I18n.t("meta.#{Settings['app']['city']}.#{category.slug}.description", default: '')
    header = header.blank? ? I18n.t("meta.#{Settings['app']['city']}.#{category.root.slug}.description", default: '') : header
    header
  end

  def meta_introduction
    return  I18n.t("meta.#{Settings['app']['city']}.organizations.introduction", default: '') unless category
    introduction = I18n.t("meta.#{Settings['app']['city']}.#{category.slug}.introduction", default: '')
    introduction = introduction.blank? ? I18n.t("meta.#{Settings['app']['city']}.#{category.root.slug}.introduction", default: '') : introduction
    introduction
  end

  def view_prefix
    return nil if self === NewOrganizationsPresenter

    self.class.name.underscore.gsub('new_', '').gsub('presenter', '')
  end

  def special_case?
    OrganizationsPresenterBuilder.new(params).special_case?
  end

  def available_sortings
    %w[positive_activity_date rating title]
  end

  def sortings_links
    available_sortings.map do |value|
      {
        title: I18n.t("organization.sort.#{value}"),
        parameters: params.merge(order_by: value),
        selected: criterion == value
      }
    end
  end

  def criterion
    @criterion ||= available_sortings.include?(params[:order_by]) ? params[:order_by] : available_sortings.first
  end

  def directions
    { 'positive_activity_date' => 'desc', 'rating' => 'desc', 'title' => 'asc' }
  end

  def advanced_filter_used?
    return false if query

    !!params[:utf8]
  end

  def promoted_clients
    orgs = Organization.search {
      with :status, [:client, :client_economy, :client_standart, :client_premium]
      paginate :page => 1, :per_page => promoted_clients_per_page
      order_by :positive_activity_date, :desc
    }.results

    OrganizationDecorator.decorate orgs
  end

  def clients_results_total_count
    clients_results.total_count
  end

  def not_clients_results_total_count
    not_clients_results.total_count
  end

  def total_count
    clients_results_total_count + not_clients_results_total_count
  end

  def tile_view_clients_per_page
    14
  end

  def clients_per_page
    view_type == 'tile' ? tile_view_clients_per_page : 1_000_000
  end

  def not_clients_per_page
    42
  end

  def nearest_clients
    @clients_results ||= Organization.search {
      paginate :page => 1, :per_page => 4
      with :status, [:client, :client_economy, :client_standart, :client_premium]
      with :organization_category_slugs, category.slug if category
      with(:location ).in_radius(latitude, longitude, radius)
    }.results

    OrganizationDecorator.decorate @clients_results
  end

  def clients_results
    @clients_results ||= Organization.search {
      paginate :page => clients_page, :per_page => clients_per_page
      with :organization_features, features if features.any?
      with :organization_category_slugs, category.slug if category
      with :status, [:client, :client_economy, :client_standart, :client_premium]

      query ? keywords(query) : order_by(criterion, directions[criterion])
    }.results
  end

  def not_clients_results
    @not_clients_results ||= Organization.search {
      paginate :page => not_clients_page, :per_page => not_clients_per_page
      with :organization_features, features if features.any?
      with :organization_category_slugs, category.slug if category
      without :status, :client

      query ? keywords(query) : order_by(criterion, directions[criterion])
    }.results
  end

  %w[clients not_clients].each do |prefix|
    define_method "#{prefix}_page" do
      (params["#{prefix}_page"] || 1).to_i
    end

    define_method prefix do
      OrganizationDecorator.decorate send("#{prefix}_results")
    end

     define_method "#{prefix}_results_last_page?" do
       send("#{prefix}_results").last_page?
     end
  end
  alias_method :collection, :clients

  def minimal_clients_results_total_count
    30
  end

  def raw_not_clients_page
    return params[:not_clients_page].to_i if params[:not_clients_page]

    if view_type == 'tile'
      if params[:not_clients_page]
        params[:not_clients_page].to_i
      else
        clients_results_last_page? ? 1 : params[:not_clients_page].to_i
      end
    else
      clients_results_total_count > minimal_clients_results_total_count ? params[:not_clients_page].to_i : 1
    end
  end

  def clients_results_current_count
    clients_results_total_count - clients_page * clients_per_page
  end

  def not_clients_results_current_count
    not_clients_results_total_count - raw_not_clients_page * not_clients_per_page
  end

  def show_not_clients_in_avdanced_filter?
    true
  end
end
