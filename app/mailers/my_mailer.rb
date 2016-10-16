#encoding: utf-8

class MyMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def send_confirm_role(organization_manager)
    @om = organization_manager
    @user = @om.manager
    @organization = @om.organization
    @email = @om.email

    mail(:to => @email, :subject => '[ZnaiGorod] Подтвердите роль')
  end

  def mail_tariff_expired(organization_tariff)
    @organization = organization_tariff.organization
    @organization_tariff = organization_tariff
    mail(:to => @organization.email.split(',')[0], :subject => '[ZnaiGorod] Срок действия тарифа истёк') if @organization.email.present?
  end

  def about_make_thier_request(request)
    @request = request
    @user = User.find(request.user_id)
    @organization = Organization.find(request.organization_id)
    mail(:to => Settings['mail.to_organization'], :subject => '[ZnaiGorod] Добавлена заявка на присвоение организации')
  end

  def message_about_update(review)
    @review = review
    mail :to => Settings['mail']['to_review'], :subject => "Обзор #{@review.title} был изменён."
  end

  def update_organization(organization)
    @organization = organization
    mail :to => Settings['mail']['to_organization'], :subject => "Огранизация #{@organization.title} была изменена."
  end

  def associated_changes(organization, str)
    @organization = organization
    @string = str
    mail :to => Settings['mail']['to_organization'], :subject => "Огранизация #{@organization.title} была изменена."
  end

  def mail_new_pending_afisha(afisha)
    @afisha = afisha
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] Добавлена новая афиша')
  end

  def mail_send_review_to_moderating(review)
    @review = review
    mail(:to => Settings['mail']['to_review'], :subject => '[ZnaiGorod] Обзор на модерацию')
  end

  def mail_new_published_afisha(afisha)
    @afisha = afisha
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] Опубликована новая афиша')
  end

  def send_to_published_organization(organization)
    @organization = organization
    mail(:to => Settings['mail']['to_organization'], :subject => '[ZnaiGorod] Подана заявка на публикацию заведения')
  end

  def send_afisha_diff(version)
    @version = version
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] Изменилась афиша')
  end

  def send_movie_sync_complete(message)
    @message = message
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] Импорт сеансов выполнен')
  end

  def send_movie_sync_error(message)
    @message = message
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] При импорте сеансов возникла ошибка')
  end

  def mail_new_published_discount(discount)
    @discount = discount
    mail(:to => Settings['mail']['to_discount'], :subject => '[ZnaiGorod] Опубликована новая скидка')
  end

  def mail_new_published_review(review)
    @review = review
    mail(:to => Settings['mail']['to_obzor'], :subject => '[ZnaiGorod] Опубликован новый обзор')
  end

  def mail_new_answer(answer)
    @answer = answer
    @question = answer.commentable
    @user = answer.account

    mail(:to => @question.account.email, :subject => '[ZnaiGorod] Ответили на ваш вопрос') if @question.account.email?
  end
end
