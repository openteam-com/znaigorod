# encoding: utf-8

class My:: CertificatesController < My::ApplicationController
  load_and_authorize_resource

  actions :new, :create, :edit, :update

  def new
    new! { render 'my/discounts/new' and return }
  end

  def create
    create! do |success, failure|
      success.html { redirect_to my_discount_path(resource) and return }
      failure.html { render 'my/discounts/new' and return }
    end
  end

  def update
    update! {
      redirect_to my_discount_path(resource) and return
    }
  end

  private
    alias_method :old_build_resource, :build_resource

    def build_resource
      old_build_resource.tap do |object|
        object.payment_system = :robokassa
        object.account = current_user.account
      end
    end
end
