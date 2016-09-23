class ReviewMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def send_to_draft(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор '#{@review.title}' отправлен в черновики."
  end

  def send_to_published(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор '#{@review.title}' опубликован"
  end

  def send_to_payment(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор '#{@review.title}' допущен к публикации."
  end
end
