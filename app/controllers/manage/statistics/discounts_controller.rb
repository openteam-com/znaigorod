class Manage::Statistics::DiscountsController < Manage::ApplicationController
  authorize_resource :discount

  def index
    @state = state = params[:state].present? ? params[:state] : nil
    page = params[:page].to_i.zero? ? 1 : params[:page]

    search = Copy.search(:include => :copyable) {
      keywords params[:q]
      group :copyable_id_str
      order_by :id, :desc
      paginate :page => page, :per_page => 10
      with :copyable_type, 'Discount'
      with :state, state if state.present?
    }

    @groups = search.group(:copyable_id_str).groups
    discounts = Discount.where(:id => @groups.map(&:value)).order('id DESC')
    @grouped_discounts = GroupedDiscounts.new(discounts).grouped
  end

  def discount_statistic
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

    author_ids = %w[4649, 6, 2303, 8581, 18960, 14818, 15669, 26228, 30563, 30194]

    @discounts = Discount.where(:account_id => author_ids, state: 'published')
                .where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
                .order('created_at DESC')
                .group_by(&:account_id)
  end
end
