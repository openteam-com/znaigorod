class Manage::MovieFixersController < Manage::ApplicationController

  load_and_authorize_resource

  has_scope :page, :default => 1

  def create
    create! do |success, failure|
      success.html {
        redirect_to manage_movie_fixers_path
      }
      failure.html { render :new }
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to manage_movie_fixers_path
      }
      failure.html {
        render :edit
      }
    end
  end
end
