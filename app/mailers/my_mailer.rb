#encoding: utf-8

class MyMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def mail_new_pending_afisha(afisha)
    @afisha = afisha
    mail(:to => Settings['mail']['to_afisha'], :subject => '[ZnaiGorod] Добавлена новая афиша')
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
