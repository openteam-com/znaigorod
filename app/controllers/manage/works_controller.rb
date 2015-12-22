class Manage::WorksController < Manage::ApplicationController
  load_and_authorize_resource

  actions :all, :except => [:index]

  belongs_to :contest, :polymorphic => true, :optional => true
  belongs_to :photogallery, :polymorphic => true, :optional => true

  def new
    new! {
      @work_anketa = params[:anketa].present? ? params[:anketa] : @work.context.anketa_content if @work.is_contest_work? && @work.context.anketa_content.present?
    }
  end

  def create
    create! { [:manage, @work.context] }
  end

  def update
    update! { [:manage, @work.context] }
  end

  def delete_stranded_votes
    ip = params[:ip]
    users = User.where(:current_sign_in_ip => ip)
    votes = users.flat_map(&:votes)
    votes.map(&:destroy)
    users.map(&:destroy)
    redirect_to :back
  end

  private

  def build_resource
    unless params[:type].nil?
      klass = params[:type].classify.constantize
      @work = klass.new(params[:work])
      context_klass = params[:context_type].classify.constantize
      @work.context = context_klass.find(params["#{params[:context_type].underscore}_id"])

      @work
    else
      context_klass = params[:context_type].classify.constantize
      @work = context_klass.find(params["#{params[:context_type].underscore}_id"]).works.new
    end
  end
end
