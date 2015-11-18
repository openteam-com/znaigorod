Znaigorod::Application.routes.draw do
  get 'api/review_collection' => 'reviews#review_collection', :as => :review_collection_api
  get 'api/single_review' => 'reviews#single_review', :as => :single_review_api

  get '/reviews/inform' => redirect { Rails.application.routes.url_helpers.reviews_inform_path } # legacy

  namespace :my do
    resources :reviews do
      get 'add'                   => 'reviews#add',                   :on => :collection
      get 'images/add'            => 'reviews#add_images',            :on => :member
      get 'add_related_items'     => 'reviews#add_related_items',     :on => :member
      get 'linked_with/available' => 'reviews#available_linked_with', :on => :collection
      get 'poster/edit'           => 'reviews#edit_poster',           :on => :member
      get 'tags/available'        => 'reviews#available_tags',        :on => :collection

      post 'images/sort'          => 'reviews#sort_images',           :on => :member

      post :preview, :on => :collection

      put :download_album, :on => :member

      put 'publish' => 'reviews#send_to_published', :on => :member
      put 'draft'   => 'reviews#send_to_draft',     :on => :member

      Review.descendant_names_without_prefix.each do |name|
        get 'new/:type' => 'reviews#new',
          :on => :collection,
          :as => "new_#{name}",
          :defaults => { :type => name },
          :constraints => { :type => name }
      end

      resources :gallery_images, :only => [:new, :create, :destroy]
      resources :gallery_social_images, :only => :destroy
    end

    # NOTE: Used at app/views/my/gallery_images/_gallery_image.html.erb:5
    Review.descendant_names.each do |name|
      resources name, :only => :show do
        resources :gallery_images, :only => :destroy
        resources :gallery_social_images, :only => :destroy
      end
    end

    resources :questions, except: :show do
      post :preview, :on => :collection
    end
  end

  namespace :manage do
    resources :reviews do
      resources :gallery_images, :except => [:index, :show] do
        delete 'destroy_file', :on => :member, :as => :destroy_file
      end

      resources :gallery_social_images, :only => [:edit, :update, :destroy]
      resources :webanketas, :except => :index

      get 'poster/edit' => 'reviews#edit_poster',       :on => :member
      get 'images/add'  => 'reviews#add_images',        :on => :member
      put 'publish'     => 'reviews#send_to_published', :on => :member
      put 'draft'       => 'reviews#send_to_draft',     :on => :member
    end

    # TODO: Used at app/views/manage/gallery_images/_gallery_image.html.erb:5
    Review.descendant_names.each do |name|
      resources name, :only => :show do
        resources :gallery_images,        :only => :destroy
        resources :gallery_social_images, :only => [:edit, :update, :destroy]
        resources :webanketas,            :except => :index
      end
    end
  end

  Review.descendant_names_without_prefix.each do |type|
    # /reviews/[article|photo|video]
    get "reviews/#{type}" => 'reviews#index', :constraints => { :type => type }, :defaults => { :type => type }

    # /reviews/[discount|certificate|coupon]/[auto|beauty|sport|...]
    Review.categories.values.each do |category|
      get "reviews/#{type}/#{category}" => 'reviews#index', :constraints => { :category => category, :type => type }, :defaults => { :category => category, :type => type }
    end

    # comments and votes
    resources "#{Review.prefix}#{type.pluralize}", :only => [] do
      resources :comments, :only => [:new, :show, :create]

      put 'change_vote' => 'votes#change_vote', :as => :change_vote
    end
  end

  # /reviews/[auto|beauty|sport|...]
  (Review.categories.values.to_a - ['inform']).each do |category|
    get "reviews/#{category}" => 'reviews#index', :constraints => { :category => category }, :defaults => { :category => category }
  end

  get "inform" => 'reviews#index', :constraints => { :category => 'inform' }, :defaults => { :category => 'inform' }, :as => :reviews_inform

  # /reviews/:year-:month/:id support
  ([Review.name.underscore] + Review.descendant_names).map(&:pluralize).each do |type|
    get  "/#{type}/*review_id/comments/new" => 'comments#new'
    get  "/#{type}/*review_id/comments/:id" => 'comments#show'

    post "/#{type}/*review_id/comments" => 'comments#create'

    get  "/#{type}/*id" => 'reviews#show', :as => type.singularize

    put "/#{type}/*review_id/change_vote" => 'votes#change_vote'
  end

  resources :reviews, :only => [:index, :show] do
    resources :comments, :only => [:new, :show, :create]

    put 'change_vote' => 'votes#change_vote', :as => :change_vote
  end

  Question.categories.values.each do |category|
    get "/questions/#{category}" => 'questions#index', :defaults => { :category => category }, :constraints => { :category => category }
  end

  resources :questions, :only => [:index, :show] do
    resources :comments, :only => [:new, :show, :create]
    put 'change_vote' => 'votes#change_vote', :as => :change_vote
  end

  # legacy
  get 'posts'              => redirect('/reviews')
  get 'posts/with_gallery' => redirect('/reviews/photo')
  get 'posts/with_video'   => redirect('/reviews/video')

  Review.categories.values.each do |category|
    get "posts/#{category}" => redirect("/reviews/#{category}")
  end

  get 'posts/:id' => redirect { |params, req| "/reviews/#{params[:id]}" }
end
