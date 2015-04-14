HasSearcher.create_searcher :actual_organization do
  models :meal, :entertainment, :culture, :sauna

  property :meal_offer
  property :meal_category

  property :entertainment_category
  property :entertainment_offer

  property :culture_category
  property :culture_offer

  property :sauna_category
  property :sauna_offer

  scope do
    #adjust_solr_params { |params| params[:q] = "{!boost b=organization_rating_f}*:*" }
    order_by(:organization_total_rating, :desc)
  end
end


HasSearcher.create_searcher :organizations do
  models :organization

  keywords :search_query do
    fields :title
  end

  property :status
  property :state
  property :sms_claimable

  property :location do |search|
    search.with(:location).in_bounding_box(
      [search_object.location[:ax], search_object.location[:ay]],
      [search_object.location[:bx], search_object.location[:by]]
    ) if search_object.location &&
      search_object.location[:ax] && search_object.location[:ax] &&
      search_object.location[:bx] && search_object.location[:bx]
  end

  scope :with_logotype do
    with(:logotyped, true)
  end

  scope :order_by_rating do
    order_by(:total_rating, :desc)
  end
  scope(:order_by_activity) { order_by :positive_activity_date, :desc }

  scope :only_clients do
    with(:status, [:client, :client_economy, :client_standart, :client_premium])
  end

  scope :without_clients do
    with(:status, [:debtor,:non_cooperation, :fresh, :waiting_for_payment, :talks])
  end

  scope(:order_by_title) { order_by :title }

  property :without do |search|
    if organization = Organization.find_by_id(search_object.without.to_i)
      search.without(organization)
    end
  end
end

HasSearcher.create_searcher :manage_organization do
  models :organization

  keywords :q

  property :status
  property :user_id
  property :suborganizations
  property :barter_status
end

HasSearcher.create_searcher :photogalleries do
  models :photogalleries

  keywords :q do
    fields :title
  end

  scope(:order_by_title) { order_by :title }
end

HasSearcher.create_searcher :global do
  models :organization, :afisha, :review, :account, :discount

  property :search_kind do |search|
    search.with(:search_kind, search_object.search_kind) if search_object.search_kind.try(:present?)
  end

  keywords :q do
    highlight :title_translit
    highlight :description_ru
    highlight :address_ru
    highlight :title

    HitDecorator::ADDITIONAL_FIELDS.each do |field|
      if (Organization.instance_methods + Afisha.instance_methods + Review.instance_methods + Account.instance_methods).include? :"#{field}_ru"
        highlight "#{field}_ru"
      else
        highlight field
      end
    end

    boost 1 do
      any_of do
        with(:last_showing_time).greater_than(DateTime.now.beginning_of_day)
        with(:kind, ['organization'])
      end
    end

    boost(
      function {
        sum(
          div(:total_rating, Afisha.maximum(:total_rating)),
          div(:total_rating, Organization.maximum(:total_rating))
        )
      }
    )
  end

  scope do
    any_of do
      all_of do
        with :class, [Account, Organization, Review]
      end

      all_of do
        with :class, [Discount, Coupon, Certificate, ReviewArticle, ReviewPhoto, ReviewVideo]
        without :state, [:draft, :pending]
        without :category, :eighteen_plus
      end

      all_of do
        with :class, Afisha
        without :state, :draft
        with(:last_showing_time).greater_than DateTime.now.beginning_of_day
      end
    end

    adjust_solr_params do |params|
      (params[:qf] || '').gsub!(/\bterm_text\b/, '')
      params[:fl] = 'id score'
    end
  end
end
