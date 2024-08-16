class Preference < ApplicationRecord
  belongs_to :user
  validates :timer_duration, :break_duration, :long_break_duration, presence: true
end