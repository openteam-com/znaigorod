# encoding: utf-8

Znaigorod::Application.routes.draw do
  namespace :my do
    resources :sessions,  :only => [:new, :destroy]

    get '/afisha/available_tags' => 'afishas#available_tags', :as => :available_tags, :controller => 'afishas'

    put 'read_all_notifications' => 'notification_messages#read_all_notifications'
    post '/auto_html/to_html' => 'auto_html#to_html'

    resources :notification_messages, :only => :index do
      put 'change_message_status' => 'notification_messages#change_message_status', :on => :member, :as => :change_status
    end

    resources :dialogs, :only => [:index, :show]

    resources :invite_messages, :only => [:index, :update, :create] do
      put 'change_message_status' => 'invite_messages#change_message_status', :on => :member, :as => :change_status
    end

    resources :private_messages, :only => [:new, :create, :show] do
      put 'change_message_status' => 'private_messages#change_message_status', :on => :member, :as => :change_status
    end

    resource :account, :only => [:show, :edit, :update] do
      resources :friends, :only => :index
      resources :feeds, :only => :index

      put 'change_friendship' => 'friends#change_friendship', :as => :change_friendship

      get 'gallery_image/:gallery_image_id/as_avatar' => 'accounts#set_avatar', :as => :set_avatar
    end

    resources :gallery_images, :except => [:show, :edit, :update] do
      delete 'destroy_all', :on => :collection, :as => :destroy_all
    end

    resources :afisha, :except => [:show], :controller => 'afishas' do
      get 'edit/step/:step' => 'afishas#edit', :defaults => { :step => 'first' }, :on => :member, :as => :edit_step
      get 'available_tags' => 'afishas#available_tags', :as => :available_tags
      get 'preview_video'

      put 'social_gallery' => 'afishas#social_gallery', :on => :member, :as => :social_gallery

      put 'publish'  => 'afishas#send_to_published', :on => :member, :as => :publish
      put 'draft' => 'afishas#send_to_draft', :on => :member, :as => :draft

      delete 'destroy_image', :on => :member, :as => :destroy_image

      resources :gallery_images, :only => [:create, :destroy] do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end

      resources :gallery_files, :only => [:create, :destroy] do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end

      resources :gallery_social_images, :only => :destroy do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end

      resources :showings

      resources :bets, :only => :create do
        resources :bet_payments, :only => [:new, :create]

        put :approve, :on => :member
        put :cancel, :on => :member
      end
    end

    get "/afisha/:id" => "afishas#show", :as => :afisha_show, :controller => 'afishas'

    resources :certificates, :only => [:new, :create, :edit, :update]
    resources :coupons, :only => [:new, :create, :edit, :update]

    resources :attachments, :only => [:edit, :update]

    resources :discounts do
      get 'help' => 'discounts#help', :on => :collection, :as => :help
      get 'poster' => 'discounts#poster', :on => :member, :as => :poster
      put 'poster' => 'discounts#poster', :on => :member, :as => :poster

      put 'publish'  => 'discounts#send_to_published', :on => :member, :as => :publish
      put 'draft' => 'discounts#send_to_draft', :on => :member, :as => :draft
    end

    resources :organizations do
      resources :gallery_files, :only => [:create, :destroy] do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end
      delete 'destroy_image', :on => :member, :as => :destroy_image

      resources :gallery_images, :only => [:create, :destroy] do
        delete 'destroy_all', :on => :collection, :as => :destroy_all
      end

      resources :organizations,  :only => [:new, :create, :destroy]

    end

    get 'related_afishas' => 'related_items#afishas',             :as => 'related_afishas'
    get 'related_reviews' => 'related_items#reviews',             :as => 'related_reviews'
    get 'related_organizations' => 'related_items#organizations', :as => 'related_organizations'
    get 'related_photogalleries' => 'related_items#photogalleries', :as => 'related_photogalleries'
    get 'related_discounts' => 'related_items#discounts', :as => 'related_discounts'

    root to: 'accounts#show'
  end
end
