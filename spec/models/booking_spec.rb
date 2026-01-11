require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "validations" do
    subject { build(:booking) }

    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:status) }

    it "validates status inclusion" do
      booking = build(:booking, status: "invalid_status")
      expect(booking).not_to be_valid
      expect(booking.errors[:status]).to include("invalid_status is not a valid status")
    end

    it "allows valid status values" do
      %w[pending confirmed rejected].each do |status|
        booking = build(:booking, status: status)
        expect(booking).to be_valid
      end
    end
  end
end
