class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  has_many :buckets, dependent: :destroy
  has_one :preference, dependent: :destroy

  after_create :create_default_preference

  private

  def create_default_preference
    create_preference(
      timer_duration: 1500,
      break_duration: 300,
      long_break_duration: 1800
    )
  end
end
