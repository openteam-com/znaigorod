# encoding: utf-8

class ReservationObserver < ActiveRecord::Observer
  def after_save(reservation)
    reservation.reserveable.delay.sunspot_index
    reservation.reserveable.organization.delay.index if reservation.reserveable.class.name != 'Organization'
  end
  def after_destroy(reservation)
    reservation.reserveable.delay.sunspot_index
    reservation.reserveable.organization.delay.index if reservation.reserveable.class.name != 'Organization'
  end
end
