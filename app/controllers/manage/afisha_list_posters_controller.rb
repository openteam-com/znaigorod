class Manage::AfishaListPostersController < Manage::ApplicationController
  authorize_resource

  def index
    @afisha_list_posters = AfishaListPoster.ordered

    search = Afisha.search { fulltext params[:term]; with :state, :published }
    afishas = search.results

    respond_to do |format|
      format.html
      format.json { render :json => afishas.map { |r|  { :label => r.title, :value => r.id } } }
    end
  end

  def edit
    @afisha_list_poster = AfishaListPoster.find(params[:id])
  end

  def update
    @afisha_list_poster = AfishaListPoster.find(params[:id])
    @afisha_list_poster.update_attributes(params[:afisha_list_poster])
    Afisha.find(params[:afisha_list_poster][:afisha_id]).update_attributes(promoted_at: params[:afisha_list_poster][:expires_at]) if params[:afisha_list_poster][:expires_at]
    redirect_to manage_afisha_list_posters_index_path
  end

end
