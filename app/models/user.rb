class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseApi::Authenticatable

  has_many :rv_listings, dependent: :destroy
  has_many :bookings, dependent: :destroy
end
