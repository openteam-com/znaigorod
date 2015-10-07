class ReviewsController < ApplicationController
  include ImageHelper

  def index
    respond_to do |format|
      format.html {
        @presenter = ReviewsPresenter.new(params)
        @reviews = @presenter.decorated_collection

        @organizations = NewOrganizationsPresenter.new({})
        @discounts = DiscountsPresenter.new(params.merge({:per_page => 4, :type => "coupon"})).decorated_collection

        render :partial => 'reviews/posters', :locals => { :collection => @reviews, :height => '200', :width => '354' }, :layout => false and return if request.xhr?
      }

      format.rss do
        @presenter = ReviewsPresenter.new(params)

        render :layout => false
      end

      format.promotion {
        presenter = ReviewsPresenter.new(params.merge(:per_page => 5))

        render :partial => 'promotions/reviews', :locals => { :presenter => presenter }
      }
    end
  end

  def show
    # /reviews/:year-:month/:id support
    review = Review.published.find_by_slug(params[:id])

    unless review
      review = Review.published.find_by_old_slug(params[:id])

      redirect_to review_path(review) and return if review

      raise ActiveRecord::RecordNotFound
    end

    @review = ReviewDecorator.new(review)

    respond_to do |format|
      format.html {
        @presenter = ReviewsPresenter.new(params.merge(:category => @review.categories.map(&:value).first, :type => @review.useful_type))

        @images = Kaminari.paginate_array(@review.images).page(params[:page]).per(30)
        render :partial => 'reviews/gallery', :layout => false and return if request.xhr?

        @review.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
      }

      format.promotion {
        render :partial => 'promotions/review', :locals => { :decorated_review => @review }
      }
    end
  end

#talant API
  def review_collection
    searcher = HasSearcher.searcher(:reviews, :q => params[:q], :state => 'published')
      .without_questions
      .order_by_creation
      .paginate(page: params[:page], per_page: 12)

    reviews = {}
    searcher.results.each do |review|
      hash_info = {}.tap{ |info|
        info['image'] = resized_image_url(review.poster_image_url, 88, 50)
        info['title'] = review.title
        info['url'] = review_url(review)
        info['prefix'] = 'review'
      }
      reviews[review.id] = hash_info
    end

    render json: reviews.to_json, :callback => params['callback']
  end

  def single_review
    review = Review.find(params[:id])

    single_review = {}.tap{ |single|
      if review.is_a?(ReviewPhoto)
        single['image'] = review.all_images.limit(6).map { |photo| resized_image_url(photo.file_url, 234, 158) }
      else
        single['image'] = resized_image_url(review.poster_image_url, 370, 200)
      end
      single['description'] = review.cached_content_for_index
      single['published_at'] = review.created_at
      single['title'] = review.title
      single['url'] = review_url(review)
    }

    render json: single_review.to_json
  end
end
