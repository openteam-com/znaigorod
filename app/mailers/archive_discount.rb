class ArchiveDiscount < ActionMailer::Base
  default :from => Settings['mail']['from']

  def send_info(discount)
    @discount = discount

    mail :to => discount.account.email, :subject => "Ваша скидка #{discount.title} перемещена в архив"
  end
end
