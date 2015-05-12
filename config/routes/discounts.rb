# encoding: utf-8

Znaigorod::Application.routes.draw do
  #mount Discounts::API => '/'

  Discount.classes_subtree.map(&:name).map(&:underscore).each do |type|
    # /discounts/[discount|certificate|coupon]
    get "discounts/#{type}" => 'discounts#index', :constraints => { :type => type }, :defaults => { :type => type }

    # /discounts/[discount|certificate|coupon]/[auto|beauty|sport|...]
    Discount.kind.values.each do |kind|
      get "discounts/#{type}/#{kind}" => 'discounts#index', :constraints => { :kind => kind, :type => type }, :defaults => { :kind => kind, :type => type }
    end

    # comments
    resources type.pluralize, :only => [] do
      resources :comments, :only => [:new, :show, :create]
      resources :offers,   :only => [:new, :create]
    end
  end

  # /discounts/[auto|beauty|sport|...]
  Discount.kind.values.each do |kind|
    get "discounts/#{kind}" => 'discounts#index', :constraints => { :kind => kind }, :defaults => { :kind => kind }
  end

  resources :discounts, :only => [:index, :show] do
    resources :members,  :only => [:index, :create, :destroy]
    resources :promote_discount_payments, :only => :create
  end

  get 'offered_discount/:id' => 'discounts#show', :as => :offered_discount
end
