#encoding: utf-8

class MyMailer < ActionMailer::Base
  default :from => Settings['mail']['from']

  def mail_new_pending_afisha(afisha)
    @afisha = afisha
    mail(:to => Settings['mail']['to_afisha'], :subject => 'В ЗнайГород добавлена новая афиша')
  end

  def mail_new_published_afisha(afisha)
    @afisha = afisha
    mail(:to => Settings['mail']['to_afisha'], :subject => 'В ЗнайГород опубликована новая афиша')
  end

  def send_afisha_diff(version)
    @version = version
    mail(:to => Settings['mail']['to_afisha'], :subject => 'В ЗнайГород изменилась афиша')
  end

  def send_movie_sync_complete(message)
    @message = message
    mail(:to => Settings['mail']['to_afisha'], :subject => 'Импорт сеансов выполнен')
  end

  def send_movie_sync_error(message)
    @message = message
    mail(:to => Settings['mail']['to_afisha'], :subject => 'При импорте сеансов возникла ошибка')
  end

  def mail_new_published_discount(discount)
    @discount = discount
    mail(:to => Settings['mail']['to_discount'], :subject => 'В ЗнайГород опубликована новая скидка')
  end

  def mail_new_published_review(review)
    @review = review
    mail(:to => Settings['mail']['to_obzor'], :subject => 'В ЗнайГород опубликован новый обзор')
  end

  def mail_new_answer(answer)
    @answer = answer
    @question = answer.commentable
    @user = answer.account

    mail(:to => @question.account.email, :subject => 'В ЗнайГород ответили на ваш вопрос') if @question.account.email?
  end
end
