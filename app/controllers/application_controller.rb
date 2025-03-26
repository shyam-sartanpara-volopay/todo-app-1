class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        include Pundit::Authorization

        before_action :authenticate_user!, unless: -> { devise_controller? }
        
        rescue_from Pundit::NotAuthorizedError do |exception|
                render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
              
        
end
