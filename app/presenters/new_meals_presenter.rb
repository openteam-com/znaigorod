class NewMealsPresenter < NewOrganizationsPresenter
  attr_accessor :cuisines

  def initialize(params)
    super

    @cuisines ||= (params[:cuisines] || []).delete_if(&:blank?)
  end

  def meals_presenter
    @meals_presenter ||= MealsPresenter.new(params.merge(:page => clients_page, :not_client_page => not_clients_page))
  end
  delegate :cuisines_filter,
    to: :meals_presenter

  def clients_results
    @clients_results ||= begin
                           search = Meal.search(:include => :organization) {
                             paginate :page => clients_page, :per_page => clients_per_page

                             #with :organization_features, features if features.any?
                             with :meal_cuisine, cuisines if cuisines.any?
                             with :organization_category_slugs, category.slug if category
                             with :status, :client

                             query ? keywords(query) : order_by(criterion, directions[criterion])
                           }

                           search.results
                         end
  end

  def clients
    @clients ||= OrganizationDecorator.decorate(clients_results.map(&:organization))
  end

  def not_clients_results
    @not_clients_results ||= begin
                               search = Meal.search(:include => :organization) {
                                 paginate :page => not_clients_page, :per_page => not_clients_per_page

                                 #with :organization_features, features if features.any?
                                 with :meal_cuisine, cuisines if cuisines.any?
                                 with :organization_category_slugs, category.slug if category
                                 without :status, :client

                                 query ? keywords(query) : order_by(criterion, directions[criterion])
                               }

                               search.results
                             end
  end

  def not_clients
    @not_clients ||= OrganizationDecorator.decorate(not_clients_results.map(&:organization))
  end
end
