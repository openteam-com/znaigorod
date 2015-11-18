class My::ReviewsController < My::ApplicationController
  load_and_authorize_resource

  actions :all

  custom_actions :resource => [:add_images, :download_album, :edit_poster, :send_to_published, :send_to_draft, :sort_images]

  def index
    render :partial => 'reviews/posters', :locals => { :collection => @reviews, :height => '156', :width => '280' }, :layout => false and return if request.xhr?
  end

  def show
    show! {
      @review = ReviewDecorator.new(@review)
    }
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to params[:crop] ? poster_edit_my_review_path(resource.id) : my_review_path(resource.id)
      }

      failure.html {
        render params[:crop] ? :edit_poster : :edit
      }
    end
  end

  def preview
    build_resource

    render :partial => "my/reviews/review", :locals => { :review => ReviewDecorator.new(@review) }
  end

  def download_album
    download_album! do
      redirect_to my_review_path(@review.id) and return if params[:album_url].blank?

      @review.download_album(params[:album_url])

      redirect_to images_add_my_review_path(@review.id) and return
    end
  end

  def send_to_published
    @review = current_user.account.reviews.draft.find(params[:id])
    @review.to_published!

    redirect_to review_path(@review.slug), :notice => "Обзор «#{@review.title}» опубликован."
  end

  def send_to_draft
    @review = current_user.account.reviews.published.find(params[:id])
    @review.to_draft!

    redirect_to my_review_path(@review.id), :notice => "Обзор «#{@review.title}» возвращен в черновики."
  end

  def available_linked_with
    render :json => Reviews::LinkWith.new(params[:term]).json
  end

  def available_tags
    render :json => Reviews::Tags.new(params[:term]).tags.to_json
  end

  def sort_images
    ids = params[:attachments] || []

    sort_images! do
      ids.each_with_index do |id, index|
        image = @review.all_images.find(id)
        image.position = index
        image.save
      end

      render :nothing => true and return
    end
  end

  def add_related_items

  end

  protected

  def begin_of_association_chain
    current_user.account
  end

  def build_resource
    @review = ReviewArticle.new(params[:review]) do |review|
      review.account = current_user.account
    end
  end

  def resource_url
    @review.is_a?(ReviewPhoto) ?
      images_add_my_review_path(@review.id) :
      my_review_path(@review.id)
  end
end
