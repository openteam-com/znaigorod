class Manage::ReviewsController < Manage::ApplicationController
  load_and_authorize_resource

  actions :all, :except => [:new, :create]

  custom_actions :resource => [:add_images, :send_to_payment, :send_to_published, :send_to_draft, :edit_poster]

  has_scope :page, :default => 1

  def show
    show! {
      @review = ReviewDecorator.decorate(@review)
    }
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to params[:crop] ? poster_edit_manage_review_path(resource.id) : manage_review_path(resource.id)
      }

      failure.html {
        render params[:crop] ? :edit_poster : :edit
      }
    end
  end

  def send_to_published
    send_to_published!{
      @review.to_published!
      redirect_to manage_review_path(@review.id), :notice => "Обзор «#{@review.title}» опубликован." and return
    }
  end

  def send_to_draft
    send_to_draft!{
      @review.comment = params[:review][:comment]
      @review.to_draft!
      ReviewMailer.send_to_draft(@review).deliver
      redirect_to manage_review_path(@review.id), :notice => "Обзор «#{@review.title}» возвращен в черновики." and return
    }
  end

  def send_to_payment
    send_to_payment!{
      @review.price = params[:review][:price]
      @review.to_payment!
      ReviewMailer.send_to_payment(@review).deliver
      redirect_to manage_review_path(@review.id), :notice => "Обзор «#{@review.title}» допущен к оплате." and return
    }
  end

  private

  def collection
    @collection = Review.search {
      keywords params[:q]
      order_by :created_at, :desc
      with :category, params[:by_category] if params[:by_category].present?
      with :state, params[:by_state] if params[:by_state].present?
      paginate paginate_options.merge(:per_page => per_page)
    }.results
  end
end
