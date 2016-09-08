# encoding: utf-8

class My::AccountsController < My::ApplicationController
  skip_authorization_check
  custom_actions :resource => [:destroy_image, :set_avatar]

  def edit
    edit!{
      @friends = Kaminari.paginate_array(@account.friends.approved.map(&:friendable)).page(1).per(5)
      @account = current_user.account
    }
  end

  def update
    update!{
      render nothing: true, :status => 200 and return if request.xhr?
      if params['account'].has_key?('review_id')
        redirect_to moderating_my_review_path(params['account']['review_id']) and return
      else
        redirect_to my_root_path and return
      end
    }
  end

  def show
    show!{
      @feeds_presenter = FeedsPresenter.new(params.merge({:account_id => current_user.account.id}))
    }
  end

  def set_avatar
    set_avatar!{
      @gallery_image = GalleryImage.find(params[:gallery_image_id])
    }
  end

  protected

  def resource
    @account ||= current_user.account
  end
end
