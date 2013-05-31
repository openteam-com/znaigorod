Znaigorod::Application.routes.draw do
  namespace :manage do
    post 'red_cloth' => 'red_cloth#show'

    resources :comments,  :only => [:index, :destroy]
    resources :search,    :only => :index
    resources :sessions,  :only => [:new, :create, :destroy]

    Affiche.descendants.each do |type|
      resources type.name.underscore.pluralize do
        resources :gallery_files,  :except => [:index, :show] do
          delete 'destroy_file', :on => :member, :as => :destroy_file
        end

        resources :gallery_images, :except => [:index, :show] do
          delete 'destroy_file', :on => :member, :as => :destroy_file
        end

        resources :gallery_social_images, :except => [:index, :show]
      end

    end
    resources :affiches, only: [] do
      resources :tickets
    end

    resources :contests do
      resources :works, :except => [:index, :show]
    end

    resources :coupons
    resources :affiliate_coupons, :only => :index

    resources :affiches do
      resources :gallery_files,  :except => [:index, :show]
      resources :gallery_images, :except => [:index, :show]
      resources :gallery_social_images, :except => [:index, :show]
    end

    resources :posts do
      resources :post_images
    end

    get 'organizations/rated' => 'organizations#index', :defaults => { :rated => true }

    resources :organizations do
      Organization.available_suborganization_kinds.each do |kind|
        resource kind, :except => [:index] do
          resources :services, :except => [:index, :show]
        end
      end

      resource :meal do
        resources :menus, :except => [:index, :show]
      end

      resource :billiard, :only => [] do
        resources :pool_tables, :except => [:index, :show]
      end

      resource :sauna, :except => [] do
        resources :sauna_halls, :except => :index
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
    end

    Organization.available_suborganization_kinds.each do |kind|
      resources kind.pluralize, :only => :index do
        resources :gallery_images, :only => [:new, :create, :destroy, :edit, :update]
      end
    end

    resources :tickets, only: [:index, :edit, :update, :destroy] do
      get ':by_state' => 'tickets#index', :on => :collection, :as => :with_state
    end

    resources :payments, :only => :index

    get 'statistics' => 'statistics#index'

    namespace :admin do
      resources :users
      post "users/mass_update" => 'users#mass_update', :as => 'user/mass_update'
    end

    root :to => 'organizations#index'
  end
end
