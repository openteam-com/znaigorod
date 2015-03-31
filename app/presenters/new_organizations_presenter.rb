class NewOrganizationsPresenter
  attr_accessor :params, :category, :view_type, :order_by_param, :query

  def initialize(params)
    @params = params
    @category ||= OrganizationCategory.find_by_slug(params[:slug])
    @view_type = params[:view_type] || 'list'
    @order_by_param = params[:order_by] || 'activity'
    @query = params[:search_query].present? ? params[:search_query] : nil
  end

  # TODO: implement
  def page_header
    nil
  end

  def sortings_links
    %w[activity rating title].map do |value|
      {
        title: I18n.t("organization.sort.#{value}"),
        parameters: params.merge(order_by: value),
        selected: order_by_param == value
      }
    end
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
      with :status, :client
      with :organization_category_slugs, category.slug if category
    }.results.total_count
  end

  def not_clients_results_total_count
    not_clients_results.total_count
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
      with :organization_category_slugs, category.slug if category
      with :status, :client

      if query
        keywords query
      else
        case order_by_param
        when 'activity'
          order_by :positive_activity_date, :desc
        when 'title'
          order_by :title, :asc
        when 'rating'
          order_by :total_rating, :desc
        else
          order_by :positive_activity_date, :desc
        end
      end
    }.results
  end

  def not_clients_results
    @not_clients_results ||= Organization.search {
      paginate :page => not_clients_page, :per_page => not_clients_per_page
      with :organization_category_slugs, category.slug if category
      without :status, :client

      if query
        keywords query
      else
        case order_by_param
        when 'activity'
          order_by :positive_activity_date, :desc
        when 'title'
          order_by :title, :asc
        when 'rating'
          order_by :total_rating, :desc
        else
          order_by :positive_activity_date, :desc
        end
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
