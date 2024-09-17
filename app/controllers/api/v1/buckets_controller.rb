class Api::V1::BucketsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :set_user
  before_action :authenticate_api_v1_user!, only: %i[index create show_buckets ]

  # ログインユーザのすべてのbucketを返す
  def index
    buckets = @user.buckets
    render json: buckets
  end

  # 新しいbucketを作成する
  def create
    @bucket = @user.buckets.build(bucket_params)
    if @bucket.save
      render json: @bucket, status: :created
    else
      render json: @bucket.errors, status: :unprocessable_entity
    end
  end

  # ログインユーザの指定された期間のbucketを返す
  def show_buckets
    date = params[:date].to_date
    period = params[:period]

    case period
    when 'week'
      start_date = date.beginning_of_week.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_week.in_time_zone('Asia/Tokyo').to_time.end_of_day.to_i
      date_range = (date.beginning_of_week.to_date..date.end_of_week.to_date)
    when 'month'
      start_date = date.beginning_of_month.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_month.in_time_zone('Asia/Tokyo').to_time.end_of_day.to_i
      date_range = (date.beginning_of_month.to_date..date.end_of_month.to_date)
    when 'year'
      start_date = date.beginning_of_year.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_year.in_time_zone('Asia/Tokyo').to_time.end_of_day.to_i
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

  # リーダーボード用（week, month, allの期間ごとに上位10名の返す）
  def show_top_users
    period = params[:period]
    date = params[:date].to_date rescue Date.today

    case period
    when 'week'
      start_date = date.beginning_of_week.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_week.in_time_zone('Asia/Tokyo').to_time.end_of_day.to_i
    when 'month'
      start_date = date.beginning_of_month.in_time_zone('Asia/Tokyo').to_time.to_i
      end_date = date.end_of_month.in_time_zone('Asia/Tokyo').to_time.end_of_day.to_i
    when 'all'
      start_date = 0
      end_date = Time.now.in_time_zone('Asia/Tokyo').to_time.to_i
    else
      render json: { error: 'Invalid period' }, status: :bad_request
      return
    end

    users = User.joins(:buckets)
                .where('buckets.starttime BETWEEN ? AND ?', start_date, end_date)
                .select('users.id, users.name, users.image, SUM(buckets.duration) AS total_duration')
                .group('users.id')
                .order('total_duration DESC')
                .limit(10)

    render json: users.map { |user| { name: user.name, image: user.image, total_duration: user.total_duration } }
  end

  def show_today_buckets
    start_date = Time.now.in_time_zone('Asia/Tokyo').beginning_of_day.to_i
    end_date = Time.now.in_time_zone('Asia/Tokyo').end_of_day.to_i

    users = User.joins(:buckets)
                .where('buckets.starttime BETWEEN ? AND ?', start_date, end_date)
                .select('users.id, count(buckets.id) AS bucket_count, SUM(buckets.duration) AS total_duration')
                .group('users.id')
                .order('total_duration DESC')

    render json: users.map { |user| [user.id, { bucket_count: user.bucket_count, total_duration: user.total_duration }] }.to_h

  end

  def show_recent_rainfall
    # 現在の時間を東京時間で取得し、1時間区切りにする
    current_time = Time.now.in_time_zone('Asia/Tokyo').beginning_of_hour
    start_of_day = current_time.beginning_of_day

    # 当日の全バケットの合計時間とユーザー数を計算
    today_buckets = Bucket.where('starttime BETWEEN ? AND ?', start_of_day.to_i, current_time.end_of_day.to_i)
    total_duration = today_buckets.sum(:duration)
    user_count = today_buckets.select(:user_id).distinct.count

    # 7時間前から1時間ごとに区切る
    rainfall_data = (0..6).map do |hour_ago|
      time = current_time - hour_ago.hours

      # 1時間分のバケットデータを取得
      buckets = Bucket.where('starttime BETWEEN ? AND ?', time.to_i, (time + 59.minutes + 59.seconds).to_i)
      duration = buckets.sum(:duration)

      # 結果をハッシュにまとめる。現在時刻と一致する場合は "現在" にする
      {
        time: (time == current_time ? '現在' : time.strftime('%-H:%M')),
        duration: duration
      }
    end

    # 昇順に並べ替えて JSON を返す
    render json: {
      total_duration: total_duration,
      user_count: user_count,
      rainfall_data: rainfall_data.reverse
    }
  end


  private
  def set_user
    @user = current_api_v1_user
  end

  def bucket_params
    params.require(:bucket).permit(:filled, :duration, :storage, :starttime, :endtime)
  end
end
