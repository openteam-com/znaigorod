class NewMealsPresenter < NewOrganizationsPresenter
  def meals_presenter
    p '='*80
    p params
    @meals_presenter ||= MealsPresenter.new(params)
  end
  delegate :cuisines_filter,
    to: :meals_presenter
end
