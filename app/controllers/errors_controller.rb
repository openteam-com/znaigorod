class ErrorsController < ApplicationController
  layout 'errors'

  def not_found
    render :status => 404
  end
end
