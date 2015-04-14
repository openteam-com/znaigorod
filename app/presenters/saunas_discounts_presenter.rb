# encoding: utf-8

class SaunasDiscountsPresenter
  def initialize(args)
    @count = 10
  end

  def ids
    Organization.search { with :suborganizations, 'sauna'; paginate :page => 1, :per_page => 1000 }.hits.map(&:primary_key)
  end

  def collection
    discount_coupons = DiscountsPresenter.new({:organization_id => ids, :q => "сауны", :order_by => "random", :type => 'certificate'}).collection
    discount_offered = DiscountsPresenter.new({:organization_id => ids, :q => "сауны", :order_by => "random", :type => 'offered_discount'}).collection
    @discount_collection = discount_offered.zip(discount_coupons)
                                           .flatten.compact.first(@count)

    @discount_collection.insert(0, Discount.find('podbor-sauny-po-vashemu-zhelaniyu')) if Settings['app.city'] == 'tomsk'
  end

end
