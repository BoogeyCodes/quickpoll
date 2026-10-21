class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: error.message }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end
