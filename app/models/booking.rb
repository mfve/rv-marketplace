class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :rv_listing

  validates :status, inclusion: { in: %w(pending confirmed rejected), message: "%{value} is not a valid status" }

  scope :for_users_listings, ->(user_id) { includes(rv_listing: :user).where(rv_listing: { user_id: user_id })}
  scope :for_user, ->(user_id) { includes(:user).where(user_id: user_id)}
  scope :visible, -> (user_id) { for_users_listings(user_id).or(for_user(user_id)) }

  def confirm
    update(status: 'confirmed')
  end

  def reject
    update(status: 'rejected')
  end
end
