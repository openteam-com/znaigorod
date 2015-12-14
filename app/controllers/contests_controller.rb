class ContestsController < ApplicationController

  helper_method :page, :per_page, :current_count, :total_count, :order_by

  def index
    @contests = Contest.available
  end

  def show
    @contest = Contest.find(params[:id])
    @works = @contest.works.send("ordered_#{order_by(@contest)}").not_archived.page(page).per(@contest.is_a?(ContestVideo) ? 200 : per_page)
    @archived_works = @contest.works.send("ordered_#{order_by(@contest)}").archived.page(page).per(@contest.is_a?(ContestVideo) ? 200 : per_page)
    @winners = winner_array(@contest.slug)
    @reviews = ReviewDecorator.decorate(@contest.reviews.order('id desc'))

    render :partial => 'works/contest_list', :locals => { :current_count => current_count, :width => @contest.is_a?(ContestVideo) ? 350 : 278 , :height => @contest.is_a?(ContestVideo) ? 200 : 278 } and return if request.xhr?
  end

  def current_count
    total_count - (page.to_i * per_page)
  end

  def page
    params[:page] || 1
  end

  def per_page
    12
  end

  def total_count
    @contest.works.archived.count
  end

  protected

  def winner_array(slug)
    [].tap { |array|
      array << Work.find("pashkevich-ekaterina")
      array << Work.find("ponomareva-valentina")
      array << Work.find("aleksandrova-olga-leonidovna")
      array << Work.find("aleksandrova-olga-leonidovna")
    } if slug == 'dance-2-go-go-ladies-go'
  end

  def order_by(contest)
    params[:order_by] || contest.default_sort
  end
end
