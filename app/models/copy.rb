# encoding: utf-8

class Copy < ActiveRecord::Base
  extend Enumerize

  attr_accessible :code, :state, :row, :seat

  belongs_to :copyable, :polymorphic => true
  belongs_to :copy_payment

  has_many :smses, :as => :smsable

  before_create :set_code

  scope :by_state, ->(state) { where :state => state }

  scope :for_tickets, -> { where :copyable_type => 'Ticket' }
  scope :for_discounts, -> { where :copyable_type => 'Discount' }

  scope :for_sale, -> { by_state 'for_sale' }
  scope :reserved, -> { by_state 'reserved' }
  scope :sold,     -> { by_state 'sold' }
  scope :stale,    -> { by_state 'stale' }

  default_scope order(:id)

  enumerize :state,
    :in => [:for_sale, :reserved, :sold, :stale],
    :default => :for_sale,
    :predicates => true

  searchable do
    integer :id

    string :copyable_type
    string :state
    string(:copyable_id_str) { copyable_id.to_s }

    time :updated_at

    text :copyable_description
  end

  def reserve!
    update_attributes :state => 'reserved'
  end

  def to_s
    str = code
    str << " (#{row} ряд, #{seat} место)" if seat?
    str
  end

  def sell!
    update_attributes :state => 'sold'
  end

  def stale!
    update_attributes :state => 'stale' unless sold?
  end

  def for_sale!
    update_attribute :state, :for_sale unless sold?
  end

  def release!
    inform_purchaser

    copy_payment.cancel!

    self.copy_payment_id = nil
    self.state = 'for_sale'
    self.save
  end

  private

  def copyable_description
    case copyable
    when Ticket
      "#{copyable.afisha.showings.last.try(:organization).try(:title)} #{copyable.try(:afisha).try(:title)}"
    when Discount
      "#{copyable.title} #{copyable.organizations_titles}"
    end
  end

  def set_code
    self.code = 4.times.map { Random.rand(10) }.join
  end

  def inform_purchaser
    smses.create! :phone => copy_payment.phone, :message => 'Время ожидания платежа за билет истекло.'
  end
end

# == Schema Information
#
# Table name: copies
#
#  id              :integer          not null, primary key
#  state           :string(255)
#  code            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  copy_payment_id :integer
#  copyable_id     :integer
#  copyable_type   :string(255)
#  row             :integer
#  seat            :integer
#

