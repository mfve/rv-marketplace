class AuthenticateController < ApplicationController
  skip_before_action :authenticate_user! , only: [:sign_up, :token]
  def sign_up
    user = User.new(user_params)

    if user.save
      token_service = Devise::Api::TokensService::Create.new(resource_owner: user)
      result = token_service.call
      
      if result.success?
        token = result.value!
        render json: { token: token.access_token, expires_in: token.expires_in }, status: :created
      else
        render json: { errors: ['Token creation failed'] }, status: :internal_server_error
      end
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def token
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      token_service = Devise::Api::TokensService::Create.new(resource_owner: user)
      result = token_service.call
      
      if result.success?
        token = result.value!
        render json: { token: token.access_token, expires_in: token.expires_in }, status: :ok
      else
        render json: { errors: ['Token creation failed'] }, status: :internal_server_error
      end
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :name, :password, :password_confirmation)
  end
end