require 'rails_helper'

RSpec.describe 'Listings', type: :request do
  let(:user) { create(:user) }
  let(:token_service) { Devise::Api::TokensService::Create.new(resource_owner: user) }
  let(:token_result) { token_service.call }
  let(:token) { token_result.value! }
  let(:headers) { { 'Authorization' => "Bearer #{token.access_token}" } }

  describe 'GET /listings' do
    before do
      create(:rv_listing)
      create(:rv_listing)
    end

    it 'returns all listings' do
      get '/listings'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['listings'].length).to eq(2)
    end

    it 'does not require authentication' do
      get '/listings'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /listings/:id' do
    let(:listing) { create(:rv_listing) }

    it 'returns the listing' do
      get "/listings/#{listing.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['listing']['id']).to eq(listing.id)
    end

    it 'returns not_found for non-existent listing' do
      get '/listings/99999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /listings' do
    let(:valid_params) do
      {
        title: 'New RV',
        description: 'A great RV',
        location: 'Melbourne, VIC',
        price_per_day: '200.00'
      }
    end

    context 'with authentication' do
      it 'creates a new listing' do
        expect {
          post '/listings', params: valid_params, headers: headers
        }.to change(RvListing, :count).by(1)
      end

      it 'returns created status' do
        post '/listings', params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'associates listing with current user' do
        post '/listings', params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        # Handle both serialized and non-serialized formats
        listing_data = json['listing'] || json
        listing_id = listing_data['id']

        expect(listing_id).to be_present
        listing = RvListing.find(listing_id)
        expect(listing.user_id).to eq(user.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/listings', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /listings/:id' do
    let(:listing) { create(:rv_listing, user: user) }
    let(:update_params) { { title: 'Updated Title' } }

    context 'as owner' do
      it 'updates the listing' do
        put "/listings/#{listing.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        expect(listing.reload.title).to eq('Updated Title')
      end
    end

    context 'as non-owner' do
      let(:other_user) { create(:user) }
      let(:other_token_service) { Devise::Api::TokensService::Create.new(resource_owner: other_user) }
      let(:other_token) { other_token_service.call.value! }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_token.access_token}" } }

      it 'returns forbidden' do
        put "/listings/#{listing.id}", params: update_params, headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /listings/:id' do
    let!(:listing) { create(:rv_listing, user: user) }

    context 'as owner' do
      it 'deletes the listing' do
        expect {
          delete "/listings/#{listing.id}", headers: headers
        }.to change(RvListing, :count).by(-1)
      end

      it 'returns no_content status' do
        delete "/listings/#{listing.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
