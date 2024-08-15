class Bucket < ApplicationRecord
  validates :starttime, :endtime, numericality: { greater_than_or_equal_to: 0 }
  validates :filled, inclusion: { in: [true, false] }
  validates :duration, :storage, numericality: { greater_than: 0 }
  validate :endtime_is_greater_than_starttime

  private

  def endtime_is_greater_than_starttime
    if starttime.present? && endtime.present? && endtime <= starttime
      errors.add(:endtime, "must be greater than starttime")
    end
  end

  belongs_to :user
end
