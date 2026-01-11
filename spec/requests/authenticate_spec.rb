require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /authenticate/sign_up' do
    let(:valid_params) do
      {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/authenticate/sign_up', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns created status' do
        post '/authenticate/sign_up', params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns a token' do
        post '/authenticate/sign_up', params: valid_params
        json = JSON.parse(response.body)
        expect(json).to have_key('token')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable_entity status' do
        post '/authenticate/sign_up', params: { email: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/authenticate/sign_up', params: { email: 'invalid' }
        json = JSON.parse(response.body)
        expect(json).to have_key('errors')
      end
    end
  end

  describe 'POST /authenticate/token' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns ok status' do
        post '/authenticate/token', params: { email: 'test@example.com', password: 'password123' }
        expect(response).to have_http_status(:ok)
      end

      it 'returns a token' do
        post '/authenticate/token', params: { email: 'test@example.com', password: 'password123' }
        json = JSON.parse(response.body)
        expect(json).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post '/authenticate/token', params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        post '/authenticate/token', params: { email: 'test@example.com', password: 'wrongpassword' }
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Invalid email or password')
      end
    end
  end
end
