require 'rails_helper'

RSpec.describe CreateBookingService, type: :service do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:rv_listing) { create(:rv_listing, user: user2) }
  let(:start_date) { Date.today + 7.days }
  let(:end_date) { Date.today + 10.days }

  describe '#call' do
    context 'with valid parameters' do
      let(:service) do
        CreateBookingService.new(
          user: user1,
          rv_listing: rv_listing,
          start_date: start_date.to_s,
          end_date: end_date.to_s
        )
      end

      it 'creates a booking' do
        expect {
          service.call
        }.to change(Booking, :count).by(1)
      end

      it 'returns true' do
        expect(service.call).to be true
      end

      it 'sets booking status to pending' do
        service.call
        expect(service.booking.status).to eq('pending')
      end

      it 'has no errors' do
        service.call
        expect(service.errors).to be_empty
      end
    end

    context 'when user tries to book own listing' do
      let(:own_listing) { create(:rv_listing, user: user1) }
      let(:service) do
        CreateBookingService.new(
          user: user1,
          rv_listing: own_listing,
          start_date: start_date.to_s,
          end_date: end_date.to_s
        )
      end

      it 'does not create a booking' do
        expect {
          service.call
        }.not_to change(Booking, :count)
      end

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'adds error message' do
        service.call
        expect(service.errors).to include('You cannot book your own listing')
      end

      it 'does not set booking' do
        service.call
        expect(service.booking).to be_nil
      end
    end

    context 'with invalid date format' do
      let(:service) do
        CreateBookingService.new(
          user: user1,
          rv_listing: rv_listing,
          start_date: 'invalid-date',
          end_date: end_date.to_s
        )
      end

      it 'does not create a booking' do
        expect {
          service.call
        }.not_to change(Booking, :count)
      end

      it 'adds error message' do
        service.call
        expect(service.errors).to include('Invalid date format. Use YYYY-MM-DD')
      end
    end

    context 'when end date is before start date' do
      let(:service) do
        CreateBookingService.new(
          user: user1,
          rv_listing: rv_listing,
          start_date: end_date.to_s,
          end_date: start_date.to_s
        )
      end

      it 'does not create a booking' do
        expect {
          service.call
        }.not_to change(Booking, :count)
      end

      it 'adds error message' do
        service.call
        expect(service.errors).to include('End date must be after start date')
      end
    end

    context 'when start date is in the past' do
      let(:service) do
        CreateBookingService.new(
          user: user1,
          rv_listing: rv_listing,
          start_date: (Date.today - 1.day).to_s,
          end_date: end_date.to_s
        )
      end

      it 'does not create a booking' do
        expect {
          service.call
        }.not_to change(Booking, :count)
      end

      it 'adds error message' do
        service.call
        expect(service.errors).to include('Start date cannot be in the past')
      end
    end
  end
end
