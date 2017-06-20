# encoding: utf-8

class ReservationObserver < ActiveRecord::Observer
  def after_save(reservation)
    organization = reservation.reserveable.try(:organization)
    if organization
      reservation.reserveable.delay.sunspot_index
      organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end

  def after_destroy(reservation)
    organization = reservation.reserveable.try(:organization)
    if organization
      reservation.reserveable.delay.sunspot_index
      organization.delay.index
    else
      reservation.reserveable.delay.index
    end
  end
end
