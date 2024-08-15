# app/controllers/api/v1/auth/registrations_controller.rb
class Api::V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  private

  def sign_up_params
    params.permit(:email, :password, :password_confirmation, :name, :nickname)
  end

  def account_update_params
    params.permit(:email, :password, :password_confirmation, :name, :nickname)
  end
end
    