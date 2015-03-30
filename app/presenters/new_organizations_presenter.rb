class NewOrganizationsPresenter
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def old_presenter
    @old_presenter ||= OrganizationsCatalogPresenter.new(params)
  end

  # TODO: implement
  def page_header
    nil
  end

  def order_by_param
    params[:order_by] || 'activity'
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

  def category
    @category ||= OrganizationCategory.find_by_slug(params[:slug])
  end

  def clients
    total_count = Organization.search {
      with :status, :client
      with :organization_category_slugs, category.slug if category
    }.results.total_count

    orgs = Organization.search {
      with :status, :client
      with :organization_category_slugs, category.slug if category
      paginate :page => 1, :per_page => total_count

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
    }.results

    OrganizationDecorator.decorate orgs
  end
end
