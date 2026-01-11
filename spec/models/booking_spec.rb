require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:rv_listing) }
  end

  describe "validations" do
    subject { build(:booking) }

    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:status) }

    it "validates status inclusion" do
      booking = build(:booking, status: 'invalid_status')
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

  describe 'scopes' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:rv_listing) { create(:rv_listing, user: user2) }
    let!(:booking1) { create(:booking, user: user1, rv_listing: rv_listing) }
    let!(:booking2) { create(:booking, user: user2, rv_listing: create(:rv_listing, user: user1)) }

    describe '.for_user' do
      it 'returns bookings for a specific user' do
        expect(Booking.for_user(user1.id)).to include(booking1)
        expect(Booking.for_user(user1.id)).not_to include(booking2)
      end
    end

    describe '.for_users_listings' do
      it 'returns bookings for listings owned by a user' do
        expect(Booking.for_users_listings(user2.id)).to include(booking1)
        expect(Booking.for_users_listings(user2.id)).not_to include(booking2)
      end
    end
  end

  describe '#confirm' do
    let(:booking) { create(:booking, status: 'pending') }

    it 'updates status to confirmed' do
      booking.confirm
      expect(booking.reload.status).to eq('confirmed')
    end
  end

  describe '#reject' do
    let(:booking) { create(:booking, status: 'pending') }

    it 'updates status to rejected' do
      booking.reject
      expect(booking.reload.status).to eq('rejected')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:booking)).to be_valid
    end
  end
end
