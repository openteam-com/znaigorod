class NewTurizmIOtdyhPresenter < NewOrganizationsPresenter
  def rooms_presenter
    @rooms_presenter ||= RoomsPresenter.new(:hotel, params)
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
                             with :id, clients_organization_ids if clients_organization_ids.any?
                             with :status, :client

                             query ? keywords(query) : order_by(criterion, directions[criterion])
                           }

                           search.results
                         end
  end

  def clients_organization_ids
    hotel_ids = rooms_presenter.send(:context_id_groups).map(&:value).map(&:to_i)

    Hotel.where(:id => hotel_ids).pluck(:organization_id)
  end

  def clients_per_page
    view_type == 'tile' ?  9 : clients_results_total_count
  end

  def clients_results_total_count
    clients_organization_ids.count
  end

  def not_clients_results
    @not_clients_results ||= begin
                               search = Organization.search {
                                 paginate :page => not_clients_page, :per_page => not_clients_per_page
                                 with :id, not_clients_organization_ids if not_clients_organization_ids.any?

                                 query ? keywords(query) : order_by(criterion, directions[criterion])
                               }

                               search.results
                             end
  end

  def not_clients_organization_ids
    @not_clients_organization_ids ||= begin
                                        ids = Hotel.search_ids {
                                          fulltext query

                                          any_of do
                                            with(:with_rooms, false)
                                            without(:status, :client)
                                          end

                                          paginate(:page => 1, :per_page => 10_000)
                                        }

                                        Hotel.where(:id => ids).pluck(:organization_id)
                                      end
  end
end
