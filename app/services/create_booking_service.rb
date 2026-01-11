class CreateBookingService
  attr_reader :errors, :booking

  def initialize(user:, rv_listing:, start_date:, end_date:)
    @user = user
    @rv_listing = rv_listing
    @start_date_string = start_date
    @end_date_string = end_date
    @errors = []
  end

  def call
    return false unless valid?

    @booking = Booking.new(
      user: user,
      rv_listing: rv_listing,
      start_date: @start_date,
      end_date: @end_date,
      status: 'pending'
    )

    if booking.save
      true
    else
      @errors = booking.errors.full_messages
      false
    end
  end

  private

  def valid?
    validate_not_own_listing
    validate_dates
    errors.empty?
  end

  def validate_not_own_listing
    if rv_listing.user_id == user.id
      errors << "You cannot book your own listing"
      return false
    end
    true
  end

  def validate_dates
    begin
      @start_date = Date.parse(@start_date_string)
      @end_date = Date.parse(@end_date_string)
    rescue ArgumentError
      errors << "Invalid date format. Use YYYY-MM-DD"
      return
    end

    if @start_date >= @end_date
      errors << "End date must be after start date"
    end

    if @start_date < Date.today
      errors << "Start date cannot be in the past"
    end
  end
end
