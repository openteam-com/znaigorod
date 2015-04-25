# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :banners, :hot_offers, :page, :per_page, :page_meta

  before_filter :detect_robots_in_development if Rails.env.development?
  before_filter :update_account_last_visit_at
  before_filter :sape_init

  layout :resolve_layout

  rescue_from CanCan::AccessDenied do |exception|
    render :partial => 'commons/social_auth', layout: false and return unless current_user
    redirect_to :back, :notice => "У вас не хватает прав для выполнения этого действия"
  end

  private

  def detect_robots_in_development
    puts "\n\n"
    puts "DEBUG ---> #{request.user_agent.to_s}"
    puts "Params: #{params}"

    render :nothing => true, status: :forbidden and return if request.user_agent.to_s.match(/\(.*https?:\/\/.*\)/)
  end

  def resolve_layout
    return request.xhr? ? false : 'public_contest' if Settings['app.city'] == 'tomsk'

    return request.xhr? ? false : 'public' if Settings['app.city'] == 'sevastopol'
  end

  def page
    params[:page].blank? ? 1 : params[:page].to_i
  end

  def per_page
    @per_page ||= Settings['pagination.per_page'] || 10
  end

  def paginate_options
    {
      :page       => page,
      :per_page   => per_page
    }
  end

  def hot_offers
    all_offers[-6..-1]
  end

  def all_offers
    [
      'meals/Пиццерии',
      'meals/Завтраки',
      'meals/Бизнес-Ланч',
      'meals/Детские Кафе',
      'entertainments/Бильярдные Залы',
      'meals/Столовые',
      'meals/Кофейни',
      'meals/Wi-Fi',
      'entertainments/Боулинг',
    ]
  end

  def banners
    Affiche.with_images.with_showings.latest(4)
  end

  def update_account_last_visit_at
    return if current_user.blank? || current_user.account.blank?
    if current_user.account.last_visit_at.blank? ||
       current_user.account.last_visit_at < DateTime.now - 5.minute
      current_user.account.update_column :last_visit_at, DateTime.now
    end
  end

  def page_meta
    @current_page_meta ||= PageMeta.find_by_path request.path
  end

  def sape_init
    @sape = Sape.from_request(Settings['sape.user_id'], request)
  end
end
