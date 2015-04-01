# encoding: utf-8

class OrganizationsController < ApplicationController
  has_scope :page, :default => 1

  helper_method :scrolltrack

  before_filter :allow_cross_domain_access

  def index
    respond_to do |format|
      format.html {
        @presenter = NewOrganizationsPresenter.build(params)
        @categories = @presenter.category ? @presenter.category.root.children : OrganizationCategory.used_roots

        if request.xhr?
          if @presenter.view_type == 'list'
            render partial: 'not_client_list_view', layout: false
          else
            render partial: 'tile_view_posters', layout: false and return if params[:not_clients_page].blank?

            render partial: 'organizations/not_client_posters', layout: false
          end
        end
      }

      format.json {
        searcher = HasSearcher.searcher(:manage_organization, params).paginate(:page => params[:page], :per_page => 10)

        render :json => searcher.results
      }

      format.promotion {
        presenter = OrganizationsCatalogPresenter.new(params.merge(:per_page => 5))

        @collection = OrganizationDecorator.decorate(presenter.collection.map(&:organization))

        render :partial => 'promotions/organizations', :locals => { :presenter => presenter }
      }
    end
  end

  def add
    @presenter = OrganizationsCatalogPresenter.new(params)
  end

  def send_mail
    @presenter = OrganizationsCatalogPresenter.new(params)
  end

  def show
    if request.subdomain.blank? || !Organization.exists?(:subdomain => request.subdomain)
      @organization = Organization.find(params[:id])
    else
      @organization = Organization.find_by_subdomain(request.subdomain)
    end
    @organization = OrganizationDecorator.decorate @organization

    respond_to do |format|
      format.html  do
        @organization.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
        @visits = @organization.visits.page(1)

        case @organization.priority_suborganization_kind
        when 'sauna'
          @presenter = SaunaHallsPresenter.new(:order_by => "rating")
        else
          klass = "#{@organization.priority_suborganization_kind.pluralize}_presenter".classify.constantize
          @presenter = klass.new(:categories => [@organization.priority_suborganization.try(:categories).try(:first).try(:mb_chars).try(:downcase)],:lat => @organization.latitude, :lon => @organization.longitude, :radius => 100, :order_by => 'nearness', :per_page => 4 )
        end

        cookie = cookies['_znaigorod_afisha_list_settings'].to_s
        settings_from_cookie = {}
        settings_from_cookie = Rack::Utils.parse_nested_query(cookie) if cookie.present?
        organization_ids = [@organization.id, @organization.situated_organization_ids].flatten
        @afisha_presenter = AfishaPresenter.new(organization_ids: organization_ids, order_by: 'starts_at', page: params[:page], :per_page => 9)
        @discount_presenter = DiscountsPresenter.new(organization_id: organization_ids, :type => 'discount', order_by: settings_from_cookie.merge(params)['order_by'], page: params[:page])
        @certificate_presenter = DiscountsPresenter.new(organization_id: organization_ids, :type => 'certificate', :order_by => 'random', :page => params[:page])
        @coupon_presenter = DiscountsPresenter.new(organization_id: organization_ids, :type => 'coupon', :order_by => 'random', :page => params[:page])
        @reviews = ReviewDecorator.decorate(@organization.reviews.published.order('id desc'))

        render partial: @afisha_presenter.partial,
          locals: { afishas: @afisha_presenter.decorated_collection, :presenter => @afisha_presenter },
          layout: false and return if request.xhr?
        render layout: "organization_layouts/#{@organization.subdomain}" if @organization.client? && @organization.subdomain? && template_exists?(@organization.subdomain, 'layouts/organization_layouts')
      end

      format.promotion do
        render :partial => 'promotions/organization', :locals => { :decorated_organization => @organization }
      end
    end
  end

  def photogallery
    @organization = OrganizationDecorator.find(params[:id])
  end

  def affiche
    @organization = OrganizationDecorator.find(params[:id])
    @presenter = AfficheCollection.new(params.merge(list_settings: cookies['_znaigorod_afisha_list_settings']).merge(organization: @organization))
    render partial: @presenter.view_partial, layout: false and return if request.xhr?
  end

  def tour
    @organization = OrganizationDecorator.find(params[:id])
  end

  def in_bounding_box
    searcher = HasSearcher.searcher(:organizations, params).
      with_logotype.
      order_by_rating.
      paginate(page: 1, per_page: 100)

    data = OrganizationDecorator.decorate(searcher.results).map do |organization|
      {
        id: organization.id,
        latitude: organization.address.latitude,
        longitude: organization.address.longitude,
        category: Russian.translit(organization.category.split(',')[0].to_s.squish.gsub(' ', '_').gsub('-', '_')).downcase,
        title: organization.title,
      }
    end

    render :json => data
  end

  def details_for_balloon
    organization = OrganizationDecorator.decorate(Organization.find(params[:id]))
    data = {
      address: organization.address.to_s,
      logo: organization.logotype_url,
      phones: organization.decorated_suborganizations.first.decorated_phones,
      schedule_today: organization.decorated_suborganizations.first.schedule_today,
      title: organization.title.text_gilensize,
      url: organization.show_url,
    }

    render :json => data
  end

  def allow_cross_domain_access
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  def show_phone
    organization = Organization.find(params[:organization_id])
    organization.increment!(:phone_show_counter)
    phone = params[:single_phone] ? organization.phone.split(',').try(:first) : organization.phone
    render text: "#{phone}".html_safe and return if request.xhr?
  end

  def increment_site_link_counter
    Organization.find(params[:organization_id]).increment!(:site_link_counter)
    render :nothing => true, :status => 200 and return if request.xhr?
  end

  def scrolltrack(key)
    @organization.navigation_collection[key].present? ? 'js-scrolltrack' : ''
  end
end
