class BookingSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :status
  has_one :user
end
