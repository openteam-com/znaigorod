class My::ReservationsController < ApplicationController

  def new
    @reservation = Reservation.new
    @organization = Organization.find(params['organization_id'])
  end

  def edit
    @organization = Organization.find(params['organization_id'])
    @reservation = @organization.reservation
  end

  def create
    @organization = Organization.find(params['organization_id'])
    reservation = @organization.build_reservation(params[:reservation])
    if reservation.save
      redirect_to my_organization_path(@organization)
    else
      render :new
    end
  end

  def update
    @organization = Organization.find(params['organization_id'])
    @reservation = @organization.reservation
    @reservation.attributes = params[:reservation]
    if @reservation.save
      redirect_to my_organization_path(@organization)
    else
      render :new
    end
  end

  def destroy
    @organization = Organization.find(params['organization_id'])
    @reservation = @organization.reservation
    @reservation.destroy
    redirect_to my_organization_path(@organization)
  end
end
