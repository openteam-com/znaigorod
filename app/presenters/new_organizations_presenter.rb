class NewOrganizationsPresenter
  attr_accessor :params, :category, :view_type, :query, :features

  def initialize(params)
    @params = params
    @category ||= OrganizationCategory.find_by_slug(params[:slug])
    @view_type = params[:view_type] || 'list'
    @query = params[:search_query].present? ? params[:search_query] : nil
    @features = params[:features] || []
  end

  def self.organization_category(slug)
    OrganizationCategory.find(slug)
  end

  def self.root_category_slug(slug)
    organization_category(slug).root.slug
  end

  def self.special_case?(slug)
    %w[sauny turizm-i-otdyh kafe-i-restorany].include? root_category_slug(slug)
  end

  def special_case_advanced_filter?
  end


  def self.build(params)
    special_case?(params[:slug]) ?
      "new_#{root_category_slug(params[:slug])}_presenter".underscore.classify.constantize.new(params) :
      new(params)
  end

  # TODO: implement
  def page_header
    nil
  end

  def special_case?
    self.class.special_case? params[:slug]
  end

  def root_category_slug
    self.class.root_category_slug(params[:slug])
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
      with :status, :client
      paginate :page => 1, :per_page => 7
      order_by :positive_activity_date, :desc
    }.results

    OrganizationDecorator.decorate orgs
  end

  def clients_results_total_count
    @clients_results_total_count ||= Organization.search {
      keywords query if query
      with :organization_features, features if features.any?
      with :organization_category_slugs, category.slug if category
      with :status, :client
    }.results.total_count
  end

  def not_clients_results_total_count
    not_clients_results.total_count
  end

  def total_count
    clients_results_total_count + not_clients_results_total_count
  end

  def clients_per_page
    view_type == 'tile' ?  14 : clients_results_total_count
  end

  def not_clients_per_page
    42
  end

  def clients_results
    @clients_results ||= Organization.search {
      paginate :page => clients_page, :per_page => clients_per_page
      with :organization_features, features if features.any?
      with :organization_category_slugs, category.slug if category
      with :status, :client

      if query
        keywords query
      else
        order_by criterion, directions[criterion]
      end
    }.results
  end

  def not_clients_results
    @not_clients_results ||= Organization.search {
      paginate :page => not_clients_page, :per_page => not_clients_per_page
      with :organization_features, features if features.any?
      with :organization_category_slugs, category.slug if category
      without :status, :client

      if query
        keywords query
      else
        order_by criterion, directions[criterion]
      end
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

     define_method "#{prefix}_results_current_count" do
       send("#{prefix}_results_total_count") - (send("#{prefix}_page") * send("#{prefix}_per_page"))
     end
  end
end
