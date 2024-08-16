class Api::V1::BucketsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :set_user
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

  def show_buckets
    date = params[:date].to_date
    period = params[:period]

    case period
    when 'week'
      start_date = date.beginning_of_week.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_week.in_time_zone('Asia/Tokyo').to_time.to_i
      date_range = (date.beginning_of_week.to_date..date.end_of_week.to_date)
    when 'month'
      start_date = date.beginning_of_month.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_month.in_time_zone('Asia/Tokyo').to_time.to_i
      date_range = (date.beginning_of_month.to_date..date.end_of_month.to_date)
    when 'year'
      start_date = date.beginning_of_year.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_year.in_time_zone('Asia/Tokyo').to_time.to_i
      date_range = (date.beginning_of_year.to_date..date.end_of_year.to_date)
    else
      render json: { error: 'Invalid period' }, status: :bad_request
      return
    end

    buckets = @user.buckets.where('starttime BETWEEN ? AND ?', start_date, end_date)

    if period == 'year'
      grouped_buckets = buckets.group_by { |bucket| Time.at(bucket.starttime).in_time_zone('Asia/Tokyo').strftime('%Y-%m') }
      all_dates = (date_range.map { |d| d.strftime('%Y-%m') }.uniq).map { |m| [m, []] }.to_h
    else
      grouped_buckets = buckets.group_by { |bucket| Time.at(bucket.starttime).in_time_zone('Asia/Tokyo').strftime('%Y-%m-%d') }
      all_dates = date_range.to_a.map { |d| [d.strftime('%Y-%m-%d'), []] }.to_h
    end

    grouped_buckets.each do |date_key, bucket_list|
      all_dates[date_key] = bucket_list
    end

    render json: all_dates
  end

  private
  def set_user
    @user = current_api_v1_user
  end

  def bucket_params
    params.require(:bucket).permit(:filled, :duration, :storage, :starttime, :endtime)
  end
end