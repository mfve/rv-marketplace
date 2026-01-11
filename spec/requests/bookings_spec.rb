require 'rails_helper'

RSpec.describe 'Bookings', type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:rv_listing) { create(:rv_listing, user: user2) }

  let(:token_service1) { Devise::Api::TokensService::Create.new(resource_owner: user1) }
  let(:token1) { token_service1.call.value! }
  let(:headers1) { { 'Authorization' => "Bearer #{token1.access_token}" } }

  let(:token_service2) { Devise::Api::TokensService::Create.new(resource_owner: user2) }
  let(:token2) { token_service2.call.value! }
  let(:headers2) { { 'Authorization' => "Bearer #{token2.access_token}" } }

  describe 'GET /bookings' do
    let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing) }

    it 'returns bookings for the current user' do
      get '/bookings', headers: headers1
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('bookings')
      expect(json).to have_key('listing_bookings')
    end

    it 'requires authentication' do
      get '/bookings'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /bookings' do
    let(:valid_params) do
      {
        rv_listing_id: rv_listing.id,
        start_date: (Date.today + 7.days).to_s,
        end_date: (Date.today + 10.days).to_s
      }
    end

    context 'with valid parameters' do
      it 'creates a new booking' do
        expect {
          post '/bookings', params: valid_params, headers: headers1
        }.to change(Booking, :count).by(1)
      end

      it 'returns created status' do
        post '/bookings', params: valid_params, headers: headers1
        expect(response).to have_http_status(:created)
      end
    end

    context 'when booking own listing' do
      let(:own_listing) { create(:rv_listing, user: user1) }
      let(:own_params) do
        {
          rv_listing_id: own_listing.id,
          start_date: (Date.today + 7.days).to_s,
          end_date: (Date.today + 10.days).to_s
        }
      end

      it 'returns error' do
        post '/bookings', params: own_params, headers: headers1
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('You cannot book your own listing')
      end
    end

    context 'with invalid date format' do
      let(:invalid_params) do
        {
          rv_listing_id: rv_listing.id,
          start_date: 'invalid-date',
          end_date: (Date.today + 10.days).to_s
        }
      end

      it 'returns error' do
        post '/bookings', params: invalid_params, headers: headers1
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Invalid date format. Use YYYY-MM-DD')
      end
    end
  end

  describe 'POST /bookings/:id/confirm' do
    let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: 'pending') }

    context 'as listing owner' do
      it 'confirms the booking' do
        post "/bookings/#{booking.id}/confirm", headers: headers2
        expect(response).to have_http_status(:ok)
        expect(booking.reload.status).to eq('confirmed')
      end
    end

    context 'as non-owner' do
      it 'returns not_found' do
        post "/bookings/#{booking.id}/confirm", headers: headers1
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /bookings/:id/reject' do
    let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: 'pending') }

    context 'as listing owner' do
      it 'rejects the booking' do
        post "/bookings/#{booking.id}/reject", headers: headers2
        expect(response).to have_http_status(:ok)
        expect(booking.reload.status).to eq('rejected')
      end
    end
  end
end
