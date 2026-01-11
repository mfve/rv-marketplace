class BookingsController < ApplicationController
  before_action :set_listing_booking, only: [:confirm, :reject]

  def index
    bookings = Booking.for_user(current_user.id)
    listing_bookings = Booking.for_users_listings(current_user.id)
    render json: { listing_bookings: listing_bookings, bookings: bookings }, status: :ok
  end

  def create
    rv_listing = RvListing.find_by(id: params[:rv_listing_id])
    render json: { errors: ['Listing not found'] }, status: :not_found and return unless rv_listing

    service = CreateBookingService.new(
      user: current_user,
      start_date: params[:start_date],
      end_date: params[:end_date],
      rv_listing: rv_listing
    )

    if service.call
      render json: { booking: service.booking }, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def confirm
    if @listing_booking.confirm
      render json: { message: 'Booking confirmed' }, status: :ok
    else
      render json: { errors: @listing_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def reject
    if @listing_booking.reject
      render json: { message: 'Booking rejected' }, status: :ok
    else
      render json: { errors: @listing_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_listing_booking
    @listing_booking = Booking.for_users_listings(current_user.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Booking not found or forbidden'] }, status: :not_found and return
  end
end
