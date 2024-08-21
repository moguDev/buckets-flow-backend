class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :password, presence: true, on: :create

  after_create :create_default_preference

  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  private

  def create_default_preference
    create_preference(
      timer_duration: 1500,
      break_duration: 300,
      long_break_duration: 1800
    )
  end

  has_many :buckets, dependent: :destroy
  has_one :preference, dependent: :destroy

  mount_uploader :image, ImageUploader
end
