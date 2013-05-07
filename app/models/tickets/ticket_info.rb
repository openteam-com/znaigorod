class TicketInfo < ActiveRecord::Base
  attr_accessible :number, :original_price, :price

  belongs_to :affiche

  has_many :tickets, dependent: :destroy

  validates_presence_of :number, :original_price, :price

  after_create :create_tickets

  private

  def create_tickets
    number.times do
      tickets.create!
    end
  end
end
