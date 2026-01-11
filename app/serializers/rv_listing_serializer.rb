class RvListingSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :location, :price_per_day

  def price_per_day
    object.price_per_day.to_f
  end
end
