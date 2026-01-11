# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users
users_data = [
  { name: 'user1', email: 'user1@example.com', password: 'password1' },
  { name: 'user2', email: 'user2@example.com', password: 'password2' },
  { name: 'user3', email: 'user3@example.com', password: 'password3' }
]

users = []
users_data.each do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email])
  if user.new_record?
    user.name = user_data[:name]
    user.password = user_data[:password]
    user.password_confirmation = user_data[:password]
    user.save!
    puts "Created user: #{user_data[:name]} (#{user_data[:email]})"
  else
    puts "User already exists: #{user_data[:name]} (#{user_data[:email]})"
  end
  users << user
end

# Create listings for each user
listings_data = [
  # User1's listings
  { user: users[0], title: "User1's Luxury RV", description: "A spacious and well-equipped RV perfect for family adventures. Features modern amenities and comfortable sleeping arrangements.", location: "Sydney, NSW", price_per_day: 150.00 },
  { user: users[0], title: "User1's Cozy Cottage", description: "Charming cottage by the beach with stunning ocean views. Perfect for a relaxing getaway.", location: "Byron Bay, NSW", price_per_day: 200.00 },

  # User2's listings
  { user: users[1], title: "User2's Adventure RV", description: "Compact and efficient RV ideal for solo travelers or couples. Fully self-contained with all essentials.", location: "Melbourne, VIC", price_per_day: 120.00 },
  { user: users[1], title: "User2's Mountain Retreat", description: "Beautiful mountain cabin surrounded by nature. Great for hiking enthusiasts and nature lovers.", location: "Blue Mountains, NSW", price_per_day: 180.00 },

  # User3's listings
  { user: users[2], title: "User3's Family RV", description: "Large RV with multiple bedrooms, perfect for big families. Includes full kitchen and entertainment system.", location: "Brisbane, QLD", price_per_day: 175.00 },
  { user: users[2], title: "User3's Beach House", description: "Modern beachfront property with direct beach access. Features a pool and outdoor entertaining area.", location: "Gold Coast, QLD", price_per_day: 250.00 }
]

listings_data.each do |listing_data|
  listing = RvListing.find_or_initialize_by(
    user: listing_data[:user],
    title: listing_data[:title]
  )

  if listing.new_record?
    listing.description = listing_data[:description]
    listing.location = listing_data[:location]
    listing.price_per_day = listing_data[:price_per_day]
    listing.save!
    puts "Created listing: #{listing_data[:title]} for #{listing_data[:user].name}"
  else
    puts "Listing already exists: #{listing_data[:title]}"
  end
end
