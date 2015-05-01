# encoding: utf-8

Znaigorod::Application.routes.draw do
  mount Affiches::API => '/'
  mount Mobile::API => '/'

  get '/api/afisha_collection' => 'afishas#afisha_collection', :as => :afisha_collection_api
  get '/api/single_afisha' => 'afishas#single_afisha', :as => :single_afisha_api

  get '/afisha_tomsk_segodnya' => redirect('/afisha?period=na_segodnya')

  get "/afisha/bilety" => 'afishas#index', :as => :afisha_with_tickets_index, :defaults => {:has_tickets => true}

  resources :afisha, :only => :show, :controller => 'afishas' do
    resources :comments, :only => [:new, :show, :create]
    resources :visits

    get 'liked' => 'votes#liked', :as => :liked
    get 'photogallery' => 'afisha#photogallery', :as => :photogallery
    get 'trailer' => 'afisha#trailer', :as => :trailer

    put 'change_vote' => 'votes#change_vote', :as => :change_vote
    put 'destroy_visits' => 'visits#destroy_visits', :as => :destroy_visits
  end

  get "/afisha",
    :constraints => lambda { |req| req.query_parameters.has_key?('has_tickets') },
    :to =>  redirect { |params, req|
      other_parameters = req.query_parameters.to_h
      other_parameters.delete('has_tickets')
      parameter_string = other_parameters.to_param
      parameter_string.insert(0, "?") unless parameter_string.empty?
      "/afisha/bilety" + parameter_string
    }
    get '/tickets', :to => redirect("/afisha/bilety")

    get '/afisha' => 'afishas#index', :as => :afisha_index, :controller => 'afishas'
    get '/afisha/:id' => 'afishas#show', :as => :afisha_show, :controller => 'afishas',
      :constraints => lambda {|request| request.fullpath !~ /^\/afisha\/bilety/ }

    get '/affiches', :to => redirect('/afisha')
    get '/newyears' => redirect { |params, request| request.params.empty? ? "/afisha_newyear" : "/afisha_newyear?#{request.params.to_query}" }

    Afisha.new_afisha_url.each do |kind, url_text|
      get "/#{url_text}",
        :constraints => lambda { |req| req.query_parameters.has_key?('has_tickets') },
        :to =>  redirect { |params, req|
          other_parameters = req.query_parameters.to_h
          other_parameters.delete('has_tickets')
          parameter_string = other_parameters.to_param
          parameter_string.insert(0, "?") unless parameter_string.empty?
          "/#{url_text}/bilety" + parameter_string
        }
        get "/#{url_text}" => 'afishas#index', :as => "#{kind}_index", :defaults => { :categories => [kind], :hide_categories => true }
        get "/#{url_text}/bilety" => 'afishas#index', :as => "#{kind}_with_tickets_index", :defaults => { :categories => [kind], :hide_categories => true, :has_tickets => true }
        match "/#{url_text}/all" => redirect("/#{url_text}")
        match "/#{kind.pluralize}" => redirect("/#{url_text}")
    end

    Afisha.kind.values.each do |kind|
      get "#{kind}/:id", :to => redirect { |params, req|
        "/afisha/#{params[:id]}"
      }
      get "#{kind}/:id/photogallery", :to => redirect { |params, req|
        "/afisha/#{params[:id]}#photogallery"
      }
      get "#{kind}/:id/trailer", :to => redirect { |params, req|
        "/afisha/#{params[:id]}#trailer"
      }
    end

    get 'afisha_newyear' => 'afishas#index', :as => "newyears_index", :defaults => { :categories => ['newyear'], :hide_categories => true }
    post 'similar_afishas' => 'similar_afishas#index', :as => 'similar_afishas'
end
