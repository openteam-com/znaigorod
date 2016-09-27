# encoding: utf-8

class Payment < ActiveRecord::Base
  extend Enumerize

  belongs_to :paymentable, :polymorphic => true
  belongs_to :user

  enumerize :state, in: [:pending, :approved, :canceled], default: :pending, scope: true

  scope :approved, -> { where(:state => 'approved') }
  scope :pending,  -> { where(:state => 'pending') }
  scope :canceled, -> { where(:state => 'canceled') }
  scope :every,    -> { where('state is not null') }

  def approve!
    self.state = 'approved'
    self.save :validate => false
  end

  def cancel!
    self.state = 'canceled'
    self.save! :validate => false
  end

  def service_url
    "#{integration_module.service_url}?#{integration_helper.form_fields.to_query}"
    #"http://auth.robokassa.ru/Merchant/Index.aspx?IsTest=1&#{integration_helper.form_fields.to_query}"
  end

  private

  def payment_system
    return :robokassa unless paymentable

    paymentable.payment_system
  end

  def integration_module
    "active_merchant/billing/integrations/#{payment_system}".classify.constantize
  end

  def robokassa_args
    [id, Settings['robokassa.login'], secret: Settings['robokassa.secret_1'], amount: amount]
  end

  def rbkmoney_args
    [id, Settings['rbkmoney.account'], :amount => amount, :currency => 'RUR']
  end

  def integration_helper
    integration_module::Helper.new(*send("#{payment_system}_args")).tap do |helper|
      if helper.is_a? ActiveMerchant::Billing::Integrations::Rbkmoney::Helper
        helper.add_fields :customer, :email => email
        #helper.add_field :preference, 'bankcard'
      end
    end
  end
end

# == Schema Information
#
# Table name: payments
#
#  id               :integer          not null, primary key
#  paymentable_id   :integer
#  number           :integer
#  phone            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  paymentable_type :string(255)
#  type             :string(255)
#  amount           :float
#  details          :text
#  state            :string(255)
#  email            :string(255)
#

