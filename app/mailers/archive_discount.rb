class ArchiveDiscount < ActionMailer::Base
  default :from => Settings['mail']['from']

  def send_archived(discount)
    @discount = discount

    mail :to => discount.account.email, :subject => "Ваша скидка #{discount.title} перемещена в архив"
  end

  def send_warning(discount)
    @discount = discount

    mail :to => discount.account.email, :subject => "Ваша скидка #{discount.title} скоро будет перемещена в архив"
  end
end
