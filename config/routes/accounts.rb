# encoding: utf-8

Znaigorod::Application.routes.draw do
  if Settings['app.city'] == 'tomsk'
    match '/*path' => redirect {|p, req| "#{req.url.gsub(req.subdomain+'.', '')}"}, :constraints => lambda{|r| r.subdomain.present? && Rails.env.production?}
  end

  get 'find_users' => 'accounts#users'
  get '/znakomstva' => 'accounts#index', :as => :accounts

  get '/accounts', :to => redirect { |_, request|
    params = request.query_parameters.dup
    category = params.delete(:category).try(:from_russian_to_param)

    params.any? ? ['/znakomstva', category].compact.join('/') << "?#{params.to_query}" : ['/znakomstva', category].compact.join('/')
  }

  Inviteables.instance.transliterated_category_titles.each do |transliterated, _|
    category = transliterated.dup

    get "znakomstva/#{transliterated}" => 'accounts#index',
      :constraints => { :category => category },
      :defaults => { :category => category },
      :as => "accounts_#{category}"
  end

  resources :accounts, :only => [:index, :show] do
    put 'change_friendship' => 'friends#change_friendship', :as => :change_friendship

    resources :events, :only => :index
    resources :comments, :only => :index
    resources :friends, :only => :index
    resources :votes, :only => :index
    resources :visits, :only => :index
    resources :feeds, :only => :index
  end
end
