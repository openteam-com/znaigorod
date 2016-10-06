class My::ReviewPaymentsController < My::ApplicationController
  skip_authorization_check

  def create
    @review = Review.find(params['review_id'])
    @review_payment = @review.review_payments.new(:amount => @review.price)
    if @review_payment.save
      redirect_to @review_payment.service_url
    end
  end
end
