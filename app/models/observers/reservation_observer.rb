# encoding: utf-8

class ReservationObserver < ActiveRecord::Observer
  def after_save(reservation)
    if reservation.reserveable.class.name != 'Organization'
      reservation.reserveable.delay.sunspot_index
      reservation.reserveable.organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end
  def after_destroy(reservation)
    if reservation.reserveable.class.name != 'Organization'
      reservation.reserveable.delay.sunspot_index
      reservation.reserveable.organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end
end
