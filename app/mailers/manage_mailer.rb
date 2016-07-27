class ManageMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def message_about_publication(organization)
    @organization = organization

    mail :to => @organization.email.split(',')[0], :subject => 'Ваша организация добавлена'
  end
end
