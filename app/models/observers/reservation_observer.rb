# encoding: utf-8

class ReservationObserver < ActiveRecord::Observer
  def after_save(reservation)
    reservation.reserveable.delay.sunspot_index
    if reservation.reservaeble.class.name != 'Organization'
      reservation.reserveable.organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end
  def after_destroy(reservation)
    reservation.reserveable.delay.sunspot_index
    if reservation.reservaeble.class.name != 'Organization'
      reservation.reserveable.organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end
end
