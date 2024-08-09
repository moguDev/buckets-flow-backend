# app/controllers/api/v1/buckets_controller.rb
class Api::V1::BucketsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :set_user, only: %i[index create]
  before_action :authenticate_api_v1_user!

  def index
    buckets = @user.buckets
    render json: buckets
  end

  def create
    @bucket = @user.buckets.build(bucket_params)
    if @bucket.save
      render json: @bucket, status: :created
    else
      render json: @bucket.errors, status: :unprocessable_entity
    end
  end

  private
  def set_user
    @user = current_api_v1_user
  end

  def set_bucket
    @bucket = Bucket.find(params[:id])
  end

  def bucket_params
    params.require(:bucket).permit(:filled, :duration, :storage, :starttime, :endtime)
  end
end