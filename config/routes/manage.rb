# encoding: utf-8

Znaigorod::Application.routes.draw do
  namespace :manage do
    namespace :statistics do
      resources :invitations,   :only => :index
      resources :payments,      :only => :index
      resources :reservations,  :only => :update
      resources :sms_claims,    :only => :index
      resources :reviews,       :only => :index
      resources :afishas,       :only => :index
      resources :links,         :only => [:index, :edit, :update]

      resources :tickets, only: [:index, :edit, :update, :destroy] do
        get ':by_state' => 'tickets#index', :on => :collection, :as => :with_state
      end
      get 'ticket_statistic' => 'tickets#ticket_statistic', :as => 'ticket_statistic'

      resources :afisha,        :only => [] do
        resources :tickets
      end

      resources :offers, :only => [:index, :edit, :update, :destroy] do
        get ':by_state' => 'offers#index', :on => :collection, :as => :by_state, :constraints => { :by_state => /#{Offer.state_machine.states.map(&:name).join('|')}/ }
        put 'fire_event_state/:event' => 'offers#fire_state_event', :on => :member, :as => :fire_state_event
      end

      get 'discounts' => 'discounts#index'
      get 'discount_statistic' => 'discounts#discount_statistic', :as => 'discount_statistic'
    end

    post 'red_cloth' => 'red_cloth#show'

    resources :attachments, :only => [:edit, :update]
    resources :comments,  :only => [:index, :destroy]
    resources :page_metas
    resources :search,    :only => :index
    resources :sessions,  :only => [:new, :create, :destroy]

    resources :banners,     :except => [:show]
    resources :place_items, :except => [:show]
    resources :promotions,  :except => [:show]

    resources :main_page_reviews, :except => :show do
      post 'sort', :on => :collection
    end

    resources :main_page_posters, :except => [:new, :create, :show, :destroy]
    resources :afisha_list_posters, :except => [:new, :create, :show, :destroy]

    resources :reviews do
      get ':by_category' =>'reviews#index', :on => :collection, :as => :by_category, :constraints => {:by_category => /#{Review.categories.values.map(&:value).join('|')}/}
      get ':by_state' => 'reviews#index', :on => :collection, :as => :by_state, :constraints => { :by_state => /#{Review.state_machine.states.map(&:name).join('|')}/ }
    end

    resources :afisha, :except => [:index, :show], :controller => 'afishas' do
      get ':by_state' => 'afishas#index', :on => :collection, :as => :by_state, :constraints => { :by_state => /#{Afisha.state_machine.states.map(&:name).join('|')}/ }
      get ':by_kind' => 'afishas#index', :on => :collection, :as => :by_kind, :constraints => { :by_kind => /#{Afisha.kind.values.map(&:pluralize).join('|')}/ }
      put 'fire_event_state/:event' => 'afishas#fire_state_event', :on => :member, :as => :fire_state_event

      get 'poster' => 'afishas#poster', :on => :member, :as => :poster
      put 'poster' => 'afishas#poster', :on => :member, :as => :poster

      delete 'destroy_image', :on => :member, :as => :destroy_image


      resources :ponominalu_tickets

      resources :gallery_files,  :except => [:index, :show] do
        delete 'destroy_file', :on => :member, :as => :destroy_file
      end
      resources :gallery_images, :except => [:index, :show] do
        delete 'destroy_file', :on => :member, :as => :destroy_file
      end
      resources :gallery_social_images, :except => [:index, :show] do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end
    end

    resources :movie_fixers

    get "/afisha" => "afishas#index", :as => :afisha_index, :controller => 'afishas'
    get "/afisha/:id" => "afishas#show", :as => :afisha_show, :controller => 'afishas'

    get '/movies_from_kinopoisk' => 'afishas#movies_from_kinopoisk', :as => :movies_from_kinopoisk
    get '/movie_info_from_kinopoisk/:movie_id' => 'afishas#movie_info_from_kinopoisk', :as => :movie_info_from_kinopoisk

    resources :contests do
      resources :works, :except => [:index] do
        delete 'delete_stranded_votes', :on => :collection
        delete 'delete_stranded_grouped_votes', :on => :collection
      end
    end

    resources :photogalleries do
      resources :works, :except => [:index, :show]
    end

    resources :certificates,      :except => [:index, :show, :destroy]
    resources :coupons,           :except => [:index, :show, :destroy]
    resources :offered_discounts, :except => [:index, :show, :destroy]

    resources :discounts do
      get ':by_state' => 'discounts#index', :on => :collection, :as => :by_state, :constraints => { :by_state => /#{Discount.state_machine.states.map(&:name).join('|')}/ }
      get ':by_kind' => 'discounts#index', :on => :collection, :as => :by_kind, :constraints => { :by_kind => /#{Discount.kind.values.map(&:pluralize).join('|')}/ }
      get 'poster' => 'discounts#poster', :on => :member, :as => :poster
      put 'poster' => 'discounts#poster', :on => :member, :as => :poster

      put 'fire_event_state/:event' => 'discounts#fire_state_event', :on => :member, :as => :fire_state_event
    end

    get 'organizations/rated' => 'organizations#index', :defaults => { :rated => true }

    resources :organizations do
      Organization.available_suborganization_kinds.each do |kind|
        resource kind, :except => [:index] do
          resources :services, :except => [:index, :show]
        end
      end

      post 'sort', :on => :collection

      resource :meal do
        resources :menus, :except => [:index, :show]
      end

      resource :billiard, :only => [] do
        resources :pool_tables, :except => [:index, :show]
      end

      resource :sauna, :except => [] do
        resources :sauna_halls, :except => :index
      end

      resource :hotel, :except => [] do
        resources :rooms, :except => :index
      end

      resource :recreation_center, :except => [] do
        resources :rooms, :except => :index
      end

      resources :rooms, :except => [] do
        resources :gallery_images, :only => [:new, :create, :destroy, :edit, :update] do
          delete 'destroy_file', :on => :member, :as => :destroy_file
        end
      end

      resources :sauna_halls, :only => [] do
        resources :gallery_images, :only => [:new, :create, :destroy, :edit, :update] do
          delete 'destroy_file', :on => :member, :as => :destroy_file
        end
      end

      resources :gallery_files,  :only => [:new, :create, :destroy, :edit, :update] do
        delete 'destroy_file', :on => :member, :as => :destroy_file
      end

      resources :gallery_images, :only => [:new, :create, :destroy, :edit, :update] do
        delete 'destroy_file', :on => :member, :as => :destroy_file
      end

      resources :organizations,  :only => [:new, :create, :destroy]

      resources :sections, :only => [:show, :destroy, :edit, :update] do
        post 'sort', :on => :collection

        resources :section_pages, :except => [:index, :show] do
          delete 'destroy_poster', :on => :member, :as => :destroy_poster
          post 'sort', :on => :collection
        end
      end
    end

    Organization.available_suborganization_kinds.each do |kind|
      resources kind.pluralize, :only => :index do
        resources :gallery_images, :only => [:new, :create, :destroy, :edit, :update]
      end
    end

    namespace :admin do
      resources :accounts, :only => [:index, :edit, :update]

      resources :users
      post "users/mass_update" => 'users#mass_update', :as => 'user/mass_update'
    end

    resources :webcams do
      get 'snapshot' => 'afishas#snapshot', :on => :member, :as => :snapshot
      put 'snapshot' => 'afishas#snapshot', :on => :member, :as => :snapshot
    end

    resources :map_projects do
      resources :map_layers, :except => [:index]
      resources :map_placemarks, :except =>[:index, :show] do
        post 'toggle_states' => 'map_placemarks#toggle_states', :as => :toggle_states
      end
    end

    resources :teasers do
      put 'clear' => 'teasers#clear', :on => :member, as: :clear
      resources :teaser_items, :only =>[:edit, :update]
    end

    resources :organization_categories do
      resources :features, :except => [:show, :index]
      post 'sort', :on => :collection
    end

    root :to => 'organizations#index'
  end
end
