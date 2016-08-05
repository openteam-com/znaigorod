class Manage::AfishasController < Manage::ApplicationController
  load_and_authorize_resource

  defaults :resource_class => Afisha

  custom_actions :resource => [:fire_state_event, :destroy_image]

  has_scope :page, :default => 1
  has_scope :by_state, :only => :index
  has_scope :by_kind, :only => :index

  def create
    create! do |success, failure|
      success.html {
        redirect_to manage_afisha_show_path(resource)
      }
      failure.html { render :new }
    end
  end

  def update
    update! do |success, failure|
      success.html {
        render :nothing => true and return if request.xhr?

        if params[:crop]
          redirect_to poster_manage_afisha_path(resource)
        else
          redirect_to manage_afisha_show_path(resource)
        end
      }

      failure.html {
        render :poster and return if params[:crop]

        render :edit
      }
    end
  end

  def destroy
    destroy! { manage_afisha_index_path }
  end

  def fire_state_event
    fire_state_event! {
      resource.fire_state_event(params[:event]) if resource.state_events.include?(params[:event].to_sym)

      redirect_to manage_afisha_show_path(resource.id), :notice => resource.errors.full_messages and return unless resource.errors.messages.empty?
      redirect_to manage_afisha_show_path(resource) and return
    }
  end

  def destroy_image
    destroy_image! {
      resource.poster_url = nil
      resource.poster_image.destroy
      resource.poster_image_url = nil
      resource.save(:validate => false)
      redirect_to poster_manage_afisha_path(resource) and return
    }
  end

  def movies_from_kinopoisk
    render :text => 'title param not present!', :layout => false, :status => 500 and return if params[:title].blank?
    require 'kinopoisk_parser'
    results = Rails.cache.fetch("movies_from_kinopoisk_#{params[:title].gsub(/\s+/, '_')}", :expires_in => 1.day) do
      Kinopoisk::Search.new params[:title]
    end
    @movies = results.movies.map{ |movie| { movie.id => "#{movie.title} [#{movie.year}]" } }
    render :layout => false
  end

  def movie_info_from_kinopoisk
    render :text => 'movie id param not present!', :layout => false, :status => 500 and return if params[:movie_id].blank?
    require 'kinopoisk_parser'
    movie = Rails.cache.fetch("movie_info_from_kinopoisk_#{params[:movie_id]}", :expires_in => 1.day) do
      Kinopoisk::Movie.new(params[:movie_id].to_i)
    end
    description = ""
    description += "|год|#{movie.year}|\n"
    description += "|страна|#{movie.countries.join(', ')}|\n"
    description += "|слоган|#{movie.slogan}|\n" if movie.slogan.gsub('-', '').present?
    description += "|режиссер|#{movie.directors.join(', ')}|\n" if movie.directors.delete_if{|v| v == '-'}.compact.any?
    description += "|сценарий|#{movie.writers.join(', ')}|\n" if movie.writers.delete_if{|v| v == '-'}.compact.any?
    description += "|продюсер|#{movie.producers.join(', ')}|\n" if movie.producers.delete_if{|v| v == '-'}.compact.any?
    description += "|оператор|#{movie.operators.join(', ')}|\n" if movie.operators.delete_if{|v| v == '-'}.compact.any?
    description += "|композитор|#{movie.composers.join(', ')}|\n" if movie.composers.delete_if{|v| v == '-'}.compact.any?
    description += "|художник|#{movie.art_directors.join(', ')}|\n" if movie.art_directors.delete_if{|v| v == '-'}.compact.any?
    description += "|монтаж|#{movie.editors.join(', ')}|\n" if movie.editors.delete_if{|v| v == '-'}.compact.any?
    description += "|жанр|#{movie.genres.join(', ')}|\n" if movie.genres.delete_if{|v| v == '-'}.compact.any?
    description += "|премьера (мир)|#{movie.premiere_world.gsub(/3D\z/, '')}|\n" if movie.premiere_world.present?
    description += "|премьера (РФ)|#{movie.premiere_ru.gsub(/3D\z/, '')}|\n" if movie.premiere_ru.present?
    description += "|возраст|#{movie.minimal_age}|\n" if movie.minimal_age.present?
    description += "|время|#{movie.duration}|\n" if movie.duration.present?
    description += "|в главных ролях|#{movie.actors.join(', ')}|\n\n"
    description += movie.description.gsub(/\u0097/, '—')
    hash = {}
    hash.merge!({ :url => movie.url })
    hash.merge!({ :title => movie.title })
    hash.merge!({ :original_title => movie.title_en })
    hash.merge!({ :poster => movie.poster_big })
    hash.merge!({ :description => description })
    hash.merge!({ :tags => "кино, #{movie.genres.join(', ')}" })
    hash.merge!({ :premiere => russian_date_convert(movie.premiere_ru.gsub(/3D\z/, '')) }) if movie.premiere_ru.present?
    hash.merge!({ :minimal_age => movie.minimal_age.scan(/\d+/).join })
    render :json => hash.to_json
  end

  protected

  def collection
    @afisha = params[:include_gone] ? include_gone : only_actual
  end

  def only_actual
    Afisha.search {
      keywords params[:q]
      with :state, params[:by_state] if params[:by_state].present?
      with :kind, params[:by_kind].singularize if params[:by_kind].present?
      order_by :created_at, :desc
      paginate paginate_options.merge(:per_page => per_page)

      # FIXME @evserykh fix me, please
      #adjust_solr_params do |params|
        #params[:sort] = 'recip(abs(ms(NOW,first_showing_time_dt)),3.16e-11,1,1) asc'
      #end
    }.results
  end

  def include_gone
    Afisha.search {
      keywords params[:q]
      with :state, params[:by_state] if params[:by_state].present?
      with :kind, params[:by_kind] if params[:by_kind].present?
      order_by :created_at, :desc
      paginate :page => params[:page], :per_page => per_page
    }.results
  end

  alias_method :old_build_resource, :build_resource

  def build_resource
    old_build_resource.tap do |object|
      object.user = current_user
    end
  end

  def russian_date_convert(str)
    day, month, year = str.split(' ')
    I18n.t('date.common_month_names').compact.each_with_index do |item, index|
      month = index + 1 and break if item == month.mb_chars.downcase
    end
    I18n.l(DateTime.parse([year, month, day].join('-')))
  end
end
