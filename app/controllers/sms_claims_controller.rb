class SmsClaimsController < ApplicationController
  inherit_resources

  actions :new, :create

  [Organization.available_suborganization_kinds << 'organization'].flatten.compact.each do |kind|
    belongs_to kind, optional: true
  end

  def new
    if request.xhr?
      new!
    else
      if parent.class.name != 'Organization'
        new! { redirect_to organization_path(parent.organization, :anchor => "new_sms_claim_#{parent.class.name.pluralize.underscore}_#{parent.id}") and return }
      else
        new! { redirect_to organization_path(parent, :anchor => "new_sms_claim_organizations_#{parent.id}") and return }
      end
    end
  end

  def create
    if parent.class.name != 'Organization'
      create! { parent.organization }
    else
      create! { parent }
    end
  end
end
