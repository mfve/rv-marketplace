require "rails_helper"

RSpec.describe "Listings", type: :request do
  let(:user) { create(:user) }
  let(:token_service) { Devise::Api::TokensService::Create.new(resource_owner: user) }
  let(:token) { token_service.call.value! }
  let(:headers) { { "Authorization" => "Bearer #{token.access_token}" } }

  describe "GET /listings" do
    context "happy path" do
      before do
        create(:rv_listing)
        create(:rv_listing)
      end

      it "returns all listings" do
        get "/api/listings"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["listings"].length).to eq(2)
      end
    end
  end

  describe "GET /listings/:id" do
    context "happy path" do
      let(:listing) { create(:rv_listing) }

      it "returns the listing" do
        get "/api/listings/#{listing.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["listing"]["id"]).to eq(listing.id)
      end
    end

    context "sad path" do
      it "returns not_found for non-existent listing" do
        get "/api/listings/99999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /listings" do
    let(:valid_params) do
      {
        title: "New RV",
        description: "A great RV",
        location: "Melbourne, VIC",
        price_per_day: "200.00"
      }
    end

    context "happy path" do
      it "creates a new listing" do
        expect {
          post "/api/listings", params: valid_params, headers: headers
        }.to change(RvListing, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        listing_data = json["listing"] || json
        listing = RvListing.find(listing_data["id"])
        expect(listing.user_id).to eq(user.id)
      end
    end

    context "sad path" do
      it "returns unauthorized without authentication" do
        post "/api/listings", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns errors for invalid parameters" do
        post "/api/listings", params: { title: "" }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end
  end

  describe "PUT /listings/:id" do
    let(:listing) { create(:rv_listing, user: user) }
    let(:update_params) { { title: "Updated Title" } }

    context "happy path" do
      it "updates the listing" do
        put "/api/listings/#{listing.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["listing"]["title"]).to eq("Updated Title")
        expect(listing.reload.title).to eq("Updated Title")
      end
    end

    context "sad path" do
      let(:other_user) { create(:user) }
      let(:other_token) { Devise::Api::TokensService::Create.new(resource_owner: other_user).call.value! }
      let(:other_headers) { { "Authorization" => "Bearer #{other_token.access_token}" } }

      it "returns forbidden for non-owner" do
        put "/api/listings/#{listing.id}", params: update_params, headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /listings/:id" do
    let!(:listing) { create(:rv_listing, user: user) }

    context "happy path" do
      it "deletes the listing" do
        expect {
          delete "/api/listings/#{listing.id}", headers: headers
        }.to change(RvListing, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
