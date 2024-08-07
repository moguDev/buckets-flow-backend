# app/controllers/api/v1/buckets_controller.rb
class Api::V1::BucketsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  
  before_action :authenticate_api_v1_user!

  def index
    buckets = current_api_v1_user.buckets
    render json: buckets
  end
end