class ListingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :set_rv_listing, only: [:show, :update, :destroy]
  before_action :verify_ownership, only: [:update, :destroy]

  def index
    render json: RvListing.all, status: :ok
  end

  def show
    render json: @rv_listing, status: :ok
  end

  def create
    rv_listing = RvListing.new(rv_listing_params)
    rv_listing.user_id = current_user.id

    if rv_listing.save
      render json: rv_listing, status: :created
    else
      render json: { errors: rv_listing.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @rv_listing.update(rv_listing_params)
      render json: @rv_listing, status: :ok
    else
      render json: { errors: @rv_listing.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @rv_listing.destroy
      render json: {}, status: :no_content
    else
      render json: { errors: @rv_listing.errors}, status: :unprocessable_entity
    end
  end

  private

  def rv_listing_params
    params.permit(:title, :description, :location, :price_per_day)
  end

  def set_rv_listing
    @rv_listing = RvListing.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Listing not found' }, status: :not_found and return
  end

  def verify_ownership
    unless @rv_listing.user_id == current_user.id
      render json: { error: 'Forbidden to update other users listings' }, status: :forbidden and return
    end
  end
end
