class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        
        include ActionController::Cookies
        before_action :authenticate_user!, unless: -> { devise_controller? }
        # while running in browsers enable this CSRF protection
        # include ActionController::RequestForgeryProtection

        # protect_from_forgery with: :exception
end
