class ArchiveDiscount < SparkPostMailer
  default :from => Settings['mail']['from']
  layout "notice_layout"

  def send_archived(account, discounts)
    @type = 'archive_discount'
    @account = AccountDecorator.decorate account
    @discounts = discounts

    mail(:to => account.email, :subject => "Ваши акции недоступны пользователям")
  end

  def send_warning(account, discounts)
    @type = 'archive_discount'
    @account = AccountDecorator.decorate account
    @discounts = discounts

    mail(:to => account.email, :subject => "Ваши акции скоро попадут в архив")
  end
end
