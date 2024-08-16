class Api::V1::PreferencesController < ApplicationController
  before_action :set_user
  before_action :authenticate_api_v1_user!
  before_action :set_preference, only: [:show, :update]

  def show
    render json: @preference
  end

  def create
    @preference = @user.build_preference(preference_params)
    if @preference.save
      render json: @preference, status: :created
    else
      render json: @preference.errors, status: :unprocessable_entity
    end
  end

  def update
    if @preference.update(preference_params)
      render json: @preference
    else
      render json: @preference.errors, status: :unprocessable_entity
    end
  end

  private

  def set_preference
    @preference = @user.preference
  end

  def set_user
    @user = current_api_v1_user
  end

  def preference_params
    params.require(:preference).permit(:timer_duration, :break_duration, :long_break_duration)
  end
end
