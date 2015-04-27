class WorksController < ApplicationController
  inherit_resources
  belongs_to :contest, :polymorphic => true, :optional => true
  belongs_to :photogallery, :polymorphic => true, :optional => true

  load_and_authorize_resource :only => [:new, :create]

  actions :new, :create, :show

  def create
    create! { @work.context }
  end

  def show
    show! {
      @work.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
      if @work.context.is_a?(Photogallery)
        @photogalleries = Photogallery.find(:all, :conditions => ["slug != ?", params[:photogallery_id]], :limit => 5)
        @more_photos = Photogallery.find(params[:photogallery_id])
      else
        @more_photos = Contest.find(params[:contest_id])
      end
    }
  end

  def destroy
    Work.find(params[:id]).destroy and render :nothing => true
  end

  def update
    Work.update(params[:id], :description => params[:description], :agree => params[:agree]) and render :nothing => true
  end

  def add
    @photogallery = Photogallery.find(params[:photogallery_id])

    if request.xhr?
      @work_image = WorkPhoto.new :image => params[:work_upload], :agree => '1', :account_id => current_user.account.id
      @work_image.context = @photogallery

      if @work_image.save
        render :json => {
          :files => [
            {
              :id           => @work_image.id,
              :name         => @work_image.image_file_name,
              :width        => 200,
              :height       => 170,
              :url          => view_context.resized_image_url(@work_image.image_url, 1920, 1080),
              :thumbnailUrl => view_context.resized_image_url(@work_image.image_url, 200, 170),
              :deleteUrl    => "/photogalleries/#{params[:photogallery_id]}/works/#{@work_image.id}",
              :updateUrl      => "/photogalleries/#{params[:photogallery_id]}/works/#{@work_image.id}"
            }
          ]
        }
      else
        render :json => {
          :errors =>[
            :error =>  @work_image.errors.full_messages
          ]
        }, :status => 500
      end
    end
  end

  protected

  def build_resource
    if current_user
      @work = WorkPhoto.new(params[:work])
      @work.context = Contest.find(params["contest_id"])
      @work = super.tap { |w| w.account_id = current_user.account_id }
    else
      redirect_to contest_path(params[:contest_id]) and return
    end
  end
end
