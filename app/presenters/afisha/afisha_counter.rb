# encoding: utf-8

class AfishaCounter
  include ActiveAttr::MassAssignment
  attr_accessor :categories, :presenter, :organization

  def count
    searcher.groups.group(:afisha_id_str).total
  end

  private

  def searcher
    @searcher ||= HasSearcher.searcher(:showings, @presenter.searcher_params.merge(:categories => categories)).tap do |s|
      unless @presenter.period_filter.date?
        case @presenter.period_filter.period
        when 'all'
          s.actual
        when 'na_segodnya'
          s.today.actual
        when 'na_nedelyu'
          s.week.actual
        when 'na_vyhodnye'
          s.weekend.actual
        end
      end
    end
  end
end
