class StatisticsDigestMailer < SparkPostMailer
  default :from => Settings['mail']['from']
  layout "notice_layout"
  add_template_helper(ImageHelper)
  add_template_helper(EmailDigestHelper)

  def send_digest(account, digest)
    @type = "statistics_digest"
    @account = account
    @digest = digest

    mail(:to => account.email, :subject => t("notice_mailer.statistics_digest")).deliver! unless @digest.flatten.blank?
  end
end
