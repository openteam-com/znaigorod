class SmsClaimsController < ApplicationController
  inherit_resources

  actions :new, :create

  (Organization.available_suborganization_kinds + ['afisha']).each do |kind|
    belongs_to kind, optional: true
  end

  def new
    if request.xhr?
      new!
    else
      new! { redirect_to organization_path(parent.organization, :anchor => "new_sms_claim_#{parent.class.name.pluralize.underscore}_#{parent.id}") and return }
    end
  end

  def create
    create! { parent.organization }
  end
end
