class ApplicationController < ActionController::API
  include Devise::Api::Controllers::Helpers

  before_action :authenticate_user!

  protected

  def authenticate_user!
    authenticate_devise_api_token!
  end

  def current_user
    current_devise_api_token&.resource_owner
  end
end
