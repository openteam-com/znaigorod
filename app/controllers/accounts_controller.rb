class AccountsController < ApplicationController
  inherit_resources
  actions :index, :show
  custom_actions :resource => [:follow, :unfollow]
  has_scope :page, :default => 1

  def index
    respond_to do |format|
      format.html {
        cookie = cookies['_znaigorod_accounts_list_settings'].to_s
        settings_from_cookie = {}
        settings_from_cookie = Rack::Utils.parse_nested_query(cookie) if cookie.present?

        @presenter = AccountsPresenter.new(settings_from_cookie.merge(params))
        render partial: 'accounts/account_posters', layout: false and return if request.xhr?
      }

      format.promotion {
        presenter = AccountsPresenter.new(params.merge(:per_page => 12))

        render :partial => 'promotions/accounts', :locals => { :presenter => presenter }
      }
    end
  end

  def users
    search = User.search { fulltext params['term'] }
    users = search.results
    respond_to do |format|
      format.json { render :json => users.map { |r|  { :email => r.account.email, :label => r.name, :value => r.id } } }
    end
  end

  def show
    show! {
      @presenter = AccountsPresenter.new(params)
      @feeds_presenter = FeedsPresenter.new(params)
      @account = AccountDecorator.new Account.find(params[:id])

      @account.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
    }
  end

end
