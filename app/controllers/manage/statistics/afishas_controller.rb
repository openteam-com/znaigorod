class Manage::Statistics::AfishasController < Manage::ApplicationController
  load_and_authorize_resource

  def index
    if params[:search] && params[:search]['starts_at'].present?
      @starts_at = Time.zone.parse(params[:search]['starts_at']).beginning_of_day
    else
      @starts_at = Time.zone.today.beginning_of_month
    end

    if params[:search] && params[:search]['ends_at'].present?
      @ends_at = Time.zone.parse(params[:search]['ends_at']).end_of_day
    else
      @ends_at = Time.zone.today.end_of_day
    end

    author_ids = %w[4650, 6, 2304, 8590, 18969, 14827, 18815, 30203, 2110, 30061]

    @afishas = Afisha.where(:user_id => author_ids)
                .where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
                .order('created_at DESC')
                .select { |afisha| afisha.showings.any? || afisha.constant? || afisha.affiche_schedule.present? || afisha.kind.include?('movie') }
                .group_by(&:user_id)

    showings = Afisha.where(:user_id => author_ids, state: 'published')
                .order('created_at DESC')
                .group_by(&:user_id)

    @showings = {}
    showings.each do |author, afisha|
      afishas = []
      afisha.map { |af| afishas << af if af.showings.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).present? && af.kind.exclude?('movie') }
      afishas = afishas - @afishas[author] if @afishas[author]
      @showings[author] = afishas
    end
  end
end
