class OrganizationsPresenterBuilder
  attr_accessor :slug, :params

  def initialize(params)
    @params = params
    @slug = params[:slug]
  end

  def category
    @category ||= OrganizationCategory.find(slug)
  end

  def root_category
    @root_category ||= category.root
  end

  def build
    klass = special_case? ? special_presenter_class : default_presenter_class

    klass.new(params)
  end

  def default_presenter_class
    NewOrganizationsPresenter
  end

  def special_classes
    results = {
      'saunas' => NewSaunyPresenter,
      'hostely' => NewRoomsPresenter,
      'gostevye-doma' => NewRoomsPresenter,
      'bazy-otdyha' => NewRoomsPresenter,
      'gostinitsy' => NewRoomsPresenter,
      'kafe_tomska' => NewMealsPresenter
    }

    results
  end

  def special_case?
    return false if slug.blank?

    special_classes.keys.include?(category.slug) || special_classes.keys.include?(root_category.slug)
  end

  def special_presenter_class
    special_classes[category.slug] || special_classes[root_category.slug]
  end

end
