class OrganizationRequestsController < ApplicationController
  def new
    @request = AddOrganizationRequest.new
    authorize! :new, @request
  end

  def send_mail
    @request = AddOrganizationRequest.new(params[:add_organization_request])

    if @request.valid?
      AddOrganizationMailer.delay(:queue => 'mailer').send_request(@request)

      redirect_to '/organizations/add', :flash => { :notice => 'Ваша заявка отправлена. Наши менеджеры свяжутся с вами в ближайшее время.' }
    else
      render :new
    end
  end
end
