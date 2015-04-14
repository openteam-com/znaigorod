# encoding: utf-8

class EntertainmentsPresenter
  include ActiveAttr::MassAssignment

  attr_accessor :categories,
                :features,
                :offers,
                :lat, :lon, :radius,
                :page, :per_page

  include OrganizationsPresenter

  acts_as_organizations_presenter kind: :entertainment, filters: [:categories, :features, :offers]

  # OPTIMIZE: special cases
  private

  def need_remove_duplications?
    categories_filter.selected.empty? || (categories_filter.selected.include?('бильярдные залы') && categories_filter.selected.include?('развлекательные комплексы'))
  end

  def searcher(per_page_count = per_page)
    @searcher ||= HasSearcher.searcher(pluralized_kind.to_sym, searcher_params).tap { |s|
      s.paginate(page: page, per_page: per_page_count)
      s.send("order_by_#{order_by}")
      s.only_clients
      s.remove_duplicated if need_remove_duplications?
    }
  end

  def add_advanced_categories_links(links)
    links.insert(0, {
        title: I18n.t("organization.kind.sauna"),
        klass: 'sauna',
        url: "saunas_path",
        parameters: url_parameters,
        selected: categories_filter[:selected].include?('sauna'),
        count: HasSearcher.searcher(:saunas).total
    })
  end

end
