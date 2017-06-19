# encoding: utf-8

Znaigorod::Application.routes.draw do
  namespace :crm do
    resources :slave_organizations, only: [:new, :update, :destroy]

    resources :organizations, only: [:index, :show, :edit, :update] do
      resources :activities
      resources :contacts, except: :show
    end

    resources :activities, only: :index do
      get :meetings, on: :collection
    end

    (Organization.available_suborganization_kinds + ['afisha']).each do |kind|
      resources kind.pluralize, :only => [] do
        resource :reservation, :except => :show
      end
    end

    root to: 'organizations#index'
  end
end

