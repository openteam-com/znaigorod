class Manage::TariffsController < Manage::ApplicationController
  load_and_authorize_resource
  def create
    create!{
      redirect_to manage_tariffs_path and return
    }
  end

  def update
    update!{
      redirect_to manage_tariffs_path and return
    }
  end

end
