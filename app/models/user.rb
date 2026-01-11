class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include Devise::Models::Api

  has_many :rv_listings, dependent: :destroy
  has_many :bookings, dependent: :destroy
end
