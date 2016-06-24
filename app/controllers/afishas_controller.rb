# encoding: utf-8

class AfishasController < ApplicationController
  include ImageHelper

  respond_to :html, :rss, :promotion
  helper_method :params_exist?

  def index
    raise params.inspect

    respond_to do |format|
      format.html {
        cookie = cookies['_znaigorod_afisha_list_settings'].to_s
        settings_from_cookie = {}
        settings_from_cookie = Rack::Utils.parse_nested_query(cookie) if cookie.present?

        if params[:categories].nil? && params[:page].nil?
          @decorator = AfishaListPoster.where('afisha_id is not null').actual.map{|afisha| AfishaDecorator.new Afisha.find(afisha.afisha_id)}
          @presenter = AfishaPresenter.new(settings_from_cookie.merge(params).merge(:afisha_list => @decorator.any? ? true : false).merge(:per_page => 20 - @decorator.count))
          @decorator += @presenter.decorated_collection
        else
          @presenter = AfishaPresenter.new(settings_from_cookie.merge(params))
          @decorator = @presenter.decorated_collection
        end

        @organizations = NewOrganizationsPresenter.new({:promoted_clients_per_page => 5})
        @discounts = DiscountsPresenter.new(params.merge({:per_page => 3, :type => "coupon"})).decorated_collection


        if request.xhr?
          if params[:page]
            render partial: @presenter.partial, :locals => { :afishas => @presenter.decorated_collection, :presenter => @presenter }, :layout => false and return
          end
        end
      }

      format.rss {
        @presenter = AfishaPresenter.new({})
        render :layout => false
      }

      format.promotion {
        presenter = AfishaPresenter.new(:per_page => 3)

        render :partial => 'promotions/afishas', :locals => { :presenter => presenter }
      }
    end
  end

  def show
    @afisha = AfishaDecorator.new Afisha.published.find(params[:id])
    @kind_afishas = @afisha.kind_searcher(@afisha.kind.first, @afisha.id)

    respond_to do |format|
      format.html {
        @afisha.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
        @presenter = AfishaPresenter.new(params.merge(:categories => [@afisha.kind.first]))
        @visits = @afisha.visits.page(1)
        @bet = @afisha.bets.build
        @certificates = @afisha.organization ? DiscountsPresenter.new(:organization_id => @afisha.organization.id, :type => 'certificate').decorated_collection : []
        @reviews = ReviewDecorator.decorate(@afisha.reviews.published.ordered)
        @last_reviews = ReviewsPresenter.new(:page => 1, :per_page => 6).decorated_collection
      }

      format.promotion do
        render :partial => 'promotions/afisha', :locals => { :decorated_afisha => @afisha }
      end
    end
  end

  def afisha_collection
    searcher = HasSearcher.searcher(:afishas, :q => params[:q], :state => 'published')
      .paginate(:page => params[:page], :per_page => 12)

    afishas = {}

    searcher.results.each do |afisha|
      hash_info = {}.tap{ |info|
        info['image'] = resized_image_url(afisha.image_url, 66, 87)
        info['title'] = afisha.title
        info['url'] = afisha_show_url(afisha)
        info['prefix'] = 'afisha'
      }
      afishas[afisha.id] = hash_info
    end


    render json: afishas.to_json, :callback => params['callback']
  end

  def single_afisha
    afisha = Afisha.find(params[:id])

    single_afisha = {}.tap{ |single|
      single['image'] = resized_image_url(afisha.poster_image_url, 370, 200)
      single['published_at'] = afisha.created_at
      single['title'] = afisha.title
      single['url'] = afisha_show_url(afisha)
    }

    render json: single_afisha.to_json
  end

  private

  def params_exist?
    request.url.split('?').many?
  end
end
