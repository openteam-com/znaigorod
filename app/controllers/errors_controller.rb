class ErrorsController < ApplicationController
  layout 'errors'

  def not_found
    render :status => 404
  end

  def internal_error
    render :status => 500
  end
end
