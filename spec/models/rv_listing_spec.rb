require 'rails_helper'

RSpec.describe RvListing, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:bookings) }
    it { should have_many(:messages) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:price_per_day) }
    it { should validate_numericality_of(:price_per_day).is_greater_than(0) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:rv_listing)).to be_valid
    end
  end
end
