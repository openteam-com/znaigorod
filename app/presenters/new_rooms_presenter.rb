class NewRoomsPresenter < NewOrganizationsPresenter
  def rooms_presenter
    @rooms_presenter ||= RoomsPresenter.new(:hotel, params.merge(:page => clients_page, :per_page => clients_per_page))
  end
  delegate :price_min, :price_max, :available_price_min, :available_price_max,
    :capacity, :capacity_min, :capacity_max,
    :rooms, :rooms_min, :rooms_max,
    :features_filter_css_class, :room_features_filter_css_class, :room_features,
    :to => :rooms_presenter

  def clients_results
    @clients_results ||= begin
                           search = Organization.search {
                             paginate :page => clients_page, :per_page => clients_per_page
                             with :id, clients_organization_ids

                             query ? keywords(query) : order_by(criterion, directions[criterion])
                           }

                           search.results
                         end
  end

  def clients_organization_ids
    hotel_ids = rooms_presenter.send(:context_id_groups).map(&:value).map(&:to_i)

    ids = Hotel.where(:id => hotel_ids).pluck(:organization_id)

    ids.any? ? ids : nil
  end

  def tile_view_clients_per_page
    9
  end

  def not_clients_results
    @not_clients_results ||= begin
                               search = Organization.search {
                                 paginate :page => not_clients_page, :per_page => not_clients_per_page
                                 with :id, not_clients_organization_ids if not_clients_organization_ids.any?
                                 with :organization_category_slugs, category.slug if category

                                 query ? keywords(query) : order_by(criterion, directions[criterion])
                               }

                               search.results
                             end
  end

  def not_clients_organization_ids
    @not_clients_organization_ids ||= begin
                                        search = Organization.search {
                                          paginate(:page => 1, :per_page => 10_000)

                                          with :organization_category_slugs, category.slug if category
                                          without :status, [:client, :client_economy, :client_standart, :client_premium]

                                          query ? keywords(query) : order_by(criterion, directions[criterion])
                                        }

                                        search.hits.map(&:primary_key).map(&:to_i)
                                      end
  end

  def show_not_clients_in_avdanced_filter?
    advanced_filter_used? ? false : true
  end
end
