class Crm::ReservationsController < ApplicationController
  before_filter :check_permissions

  inherit_resources

  actions :all

  belongs_to *Organization.available_suborganization_kinds, :afisha, :polymorphic => true, :optional => true

  defaults :singleton => true

  layout false

  def create
    create! do |success, failure|
      success.html { render :partial => 'reservation', :locals => { :suborganization => parent } and return }
    end
  end

  def update
    update! do |success, failure|
      success.html { render :partial => 'reservation', :locals => { :suborganization => parent } and return }
    end
  end

  def destroy
    destroy! { render :partial => 'reservation', :locals => { :suborganization => parent.reload } and return }
  end

  private

  def check_permissions
    ability = Ability.new(current_user)
    redirect_to manage_root_path unless ability.can?(:manage, :crm)
  end
end
