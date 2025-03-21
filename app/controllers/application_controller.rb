class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Cookies
  include Pundit

  # while running in browsers enable this CSRF protection
  # include ActionController::RequestForgeryProtection

  # protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: -> { devise_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end
end
