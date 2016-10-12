class ManageMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def message_about_publication(organization)
    @organization = organization

    mail :to => @organization.email.split(',')[0], :subject => 'Ваша организация опубликована'
  end

  def message_about_draft(organization)
    @organization = organization

    mail :to => @organization.email.split(',')[0], :subject => 'Ваша организация ушла в черновики'
  end


  def make_thier_allow(request)
    @request = request

    mail :to => @request.email, :subject => "Теперь организация '#{@request.organization}' ваша."
  end

  def make_thier_disallow(request)
    @request = request

    mail :to => @request.email, :subject => "Отказано в присвоении '#{@request.organization}'."
  end

  def about_clone_remove(organization, original)
    @organization = organization
    @original = original

    mail :to => @organization.user.account.email, :subject => 'Мы добавили вам существующую организацию'
  end

end
