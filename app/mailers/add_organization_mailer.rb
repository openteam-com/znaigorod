require 'add_organization_request'

class AddOrganizationMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def send_request(request)
    @request = request

    mail :to => Settings['mail']['to_office'], :subject => 'На сайте znaigorod.ru поступил запрос на добавление организации'
  end
end
