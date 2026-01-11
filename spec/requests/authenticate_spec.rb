require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "POST /authenticate/sign_up" do
    let(:valid_params) do
      {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    context "happy path" do
      it "creates a new user and returns token" do
        expect {
          post "/authenticate/sign_up", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json).to have_key("token")
      end
    end

    context "sad path" do
      it "returns errors for invalid parameters" do
        post "/authenticate/sign_up", params: { email: "invalid" }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end
  end

  describe "POST /authenticate/token" do
    let!(:user) { create(:user, email: "test@example.com", password: "password123") }

    context "happy path" do
      it "returns token for valid credentials" do
        post "/authenticate/token", params: { email: "test@example.com", password: "password123" }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("token")
      end
    end

    context "sad path" do
      it "returns unauthorized for invalid credentials" do
        post "/authenticate/token", params: { email: "test@example.com", password: "wrongpassword" }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid email or password")
      end
    end
  end
end
