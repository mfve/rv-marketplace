require "rails_helper"

RSpec.describe RvListing, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:price_per_day) }
    it { should validate_numericality_of(:price_per_day).is_greater_than(0) }
  end
end
