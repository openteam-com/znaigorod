class Manage::TeasersController < Manage::ApplicationController
  load_and_authorize_resource

  def clear
    item = @teaser.teaser_items.find(params[:teaser_item_id])
    item.image_url = nil
    item.link_text = ''
    item.url = ''
    item.save!

    redirect_to manage_teaser_path(@teaser)
  end
end
