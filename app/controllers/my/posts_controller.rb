class My::PostsController < My::ApplicationController
  load_and_authorize_resource

  def available_tags
    render :json => %w[foo bar foobar].to_json
  end

  def preview
    render :text => AutoHtmlRenderer.new(params[:text]).render
  end

  def link_with
    render :json => LinkWithAutocomplete.new(params[:term]).json
  end
end
