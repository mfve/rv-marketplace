class RvListingSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :location, :price_per_day
end