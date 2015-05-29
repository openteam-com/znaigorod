class OrganizationMailer < MandrillMailer
  default :from => "\"znaigorod.ru\" <#{Settings['mail']['from']}>"
  layout "notice_layout"

  def new_comment(comment)
    @comment = comment
    @account = AccountDecorator.decorate comment.user.account
    @organization = OrganizationDecorator.decorate comment.commentable
    @type = 'new_organization_comment'

    mail(:to => @organization.email, :subject => "На сайте ЗнайГород добавили новый отзыв к Вашему заведению \"#{@organization.title}\"")
  end
end
