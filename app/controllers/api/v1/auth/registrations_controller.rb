class Api::V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  before_action :set_user, only: %i[update_name]
  before_action :configure_account_update_params, only: [:update]

  private

  def set_user
    @user = current_api_v1_user
  end

  def sign_up_params
    params.permit(:email, :password, :password_confirmation, :name, :nickname)
  end

  def account_update_params
    params.permit(:email, :password, :password_confirmation, :name, :nickname)
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
