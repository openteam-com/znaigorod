# encoding: utf-8

Znaigorod::Application.routes.draw do
  get 'organizations/add' => "organization_requests#new"
  post 'organizations/send_mail'=> "organization_requests#send_mail"

  get '/organizations/shirli-myrli-kottedzh--2', :to => redirect('/organizations/shirli-myrli-usadba--2')
  get '/organizations/shirli-myrli-kottedzh', :to => redirect('/organizations/shirli-myrli-usadba')

  get '/:slug' => 'organizations#index',
    :constraints => { :slug => Regexp.new(OrganizationCategory.pluck(:slug).join('|')) },
    :as => :organizations_by_category

  get '/entertainments/:slug', :to => redirect { |params, req| "/#{params[:slug]}" }
  get '/car_sales_centers/:slug', :to => redirect { |params, req| "/#{params[:slug]}" }
  get '/cultures/:slug', :to => redirect { |params, req| "/#{params[:slug]}" }
  get '/creations/:slug', :to => redirect { |params, req| "/#{params[:slug]}" }
  get '/salon_centers/:slug', :to => redirect { |params, req| "/#{params[:slug]}" }

  resources :organizations, :only => [:index, :show] do
    get 'landing', on: :collection
    get 'i_agree_on_the_role', on: :collection
    get :make_their, :on => :member
    get :delete_make_their_request, :on => :member
    post :create_request_for_make_their, :on => :member
    get :in_bounding_box, :on => :collection
    get :details_for_balloon, :on => :member
    put 'change_vote' => 'votes#change_vote', :as => :change_vote
    put 'destroy_visits' => 'visits#destroy_visits', :as => :destroy_visits
    get 'liked' => 'votes#liked', :as => :liked

    resources :comments, :only => [:new, :create, :show]
    resources :visits

    resources :user_ratings, :only => [:new, :create, :edit, :update, :show]
  end

  get "/saunas",
  :constraints => lambda { |req| req.query_parameters.has_key?('categories') },
  :to =>  redirect { |params, req|
    category = req.query_parameters['categories'].first.mb_chars.downcase
    other_parameters = req.query_parameters.to_h
    other_parameters.delete('categories')
    parameter_string = other_parameters.to_param
    parameter_string.insert(0, "?") unless parameter_string.empty?
    "/saunas" + parameter_string
  }
  resources :saunas, :only => :index
  get '/saunas/sauny', :to => redirect('/saunas')
  get '/meals' => redirect { |params, request| request.params.empty? ? "/kafe_tomske" : "/kafe_tomska?#{request.params.to_query}" }
  get '/kafe_i_restorany_tomska' => redirect('/kafe_tomska')
  get '/car_washes', :to => redirect('/car_washes/avtomoyki')

  get '/recreation_centers' => 'hotels#index',
    :defaults => {:categories => ["базы отдыха"] },
    :constraints => {:categories => ["базы отдыха"] },
    :as => :hotels_bazy_otdyhas

  resources :hotels, :only => :index
  Values.instance.hotel.categories.map(&:mb_chars).map(&:downcase).map(&:to_s).each do |category|
    get "/hotels/#{category.from_russian_to_param.pluralize}" => 'hotels#index', :defaults => { :categories => [category] }, :constraints => { :categories => [category] }
  end

  Organization.available_suborganization_kinds.each do |kind|
    resources kind.pluralize, :only => [] do
      resources :sms_claims, :only => [:new, :create]
    end

    # redirects from /kind?categories[]=...
    get "/#{kind.pluralize}",
      :constraints => lambda { |req| req.query_parameters.has_key?('categories') },
      :to =>  redirect { |params, req|
        category = req.query_parameters['categories'].try(:first).try(:mb_chars).try(:downcase)
        other_parameters = req.query_parameters.to_h
        other_parameters.delete('categories')
        parameter_string = other_parameters.to_param
        parameter_string.insert(0, "?") unless parameter_string.empty?
        if category.present?
          "/#{kind.pluralize}/#{category.from_russian_to_param}" + parameter_string
        else
          "/#{kind.pluralize}" + parameter_string
        end
      }

      # short categories urls
      begin
        Values.instance.send(kind).categories.each do |category|
          next if kind == 'sauna' || kind == 'hotel'
          if kind == 'meal' || kind == 'sport'
            get "/#{kind.pluralize}/#{category.from_russian_to_param}",
            :to => redirect("/#{category.from_russian_to_param}")
            get "/#{category.from_russian_to_param}" => 'suborganizations#index',
            :as => "#{kind.pluralize}_#{category.from_russian_to_param.pluralize}".to_sym,
            :defaults => {:kind => kind, :categories => [category.mb_chars.downcase.to_s]}
          else
            get "/#{kind.pluralize}/#{category.from_russian_to_param}" => 'suborganizations#index',
            :as => "#{kind.pluralize}_#{category.from_russian_to_param.pluralize}".to_sym,
            :defaults => {:kind => kind, :categories => [category.mb_chars.downcase.to_s]}
          end
        end
      rescue
      end
      get "/#{kind.pluralize}" => 'suborganizations#index', :as => kind.pluralize, :constraints => { :kind => kind }, :defaults => { :kind => kind }

    # from legacy
    get "/#{kind.pluralize}/(:category)/(*query)",
      :constraints => lambda { |req| !req.original_fullpath.match(/^\/#{kind.pluralize}\/\d+/) },
      :to => redirect { |params, req|
        url = "/#{kind.pluralize}"
        if params[:category] == 'all'
          parameters = {}
          parameters.tap do |hash|
            keyword = ''
            params[:query].to_s.split('/').each do |word|
              keyword = word and hash[keyword] ||= [] and next if ['categories'].include?(word)
              hash[keyword] << word if hash[keyword]
            end
          end
          parameters['categories'] ||= []
          if parameters['categories'] == ['сауны']
            url = '/saunas'
          else
            url += "/#{parameters['categories'].first.from_russian_to_param}" if parameters['categories'].any?
          end
        else
          if params[:category] == 'сауны'
            url = '/saunas'
          elsif HasSearcher.searcher(kind.pluralize.to_sym).facet("#{kind}_category").rows.flat_map(&:value).include?(params[:category])
            url += "/#{params[:category].from_russian_to_param}"
          end
        end
        URI.encode(url)
    }
  end

  get '/entertainments/bilyardnye_zaly' => 'suborganizations#index', :as => :billiards, :constraints => { :kind => 'entertainments' }, :defaults => { :kind => 'entertainments' }

  get 'organizations/:id/affiche/all' => redirect { |params, req|
    o = Organization.find(params[:id])
    "/organizations/#{o.slug}"
  }

  get 'organizations/:id/tour' => redirect { |params, req|
    o = Organization.find(params[:id])
    "/organizations/#{o.slug}"
  }

  get 'organizations/:id/photogallery' => redirect { |params, req|
    o = Organization.find(params[:id])
    "/organizations/#{o.slug}"
  }

  get "/kafe_tomska" => 'suborganizations#index', :as => 'meals', :constraints => { :kind => 'meal' }, :defaults => { :kind => 'meal' }
  get "/show_phone" => "organizations#show_phone", :as => 'show_phone'
  get "/increment_site_link_counter" => "organizations#increment_site_link_counter", :as => 'increment_site_link_counter'

end
