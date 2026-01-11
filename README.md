# RV Listing Marketplace - Camplify Tech Test

A basic marketplace for creating listings for an RV Marketplace, and creating bookings

To set up:
1. Install Ruby 3.3.2 using your preferred method (rbenv example below)

```
brew install rbenv ruby-build
rbenv install 3.3.2
rbenv local 3.3.2
```
2. Install gems and bundle
```
gem install bundler
bundle install
```
3. Install and set up database
```
rails db:create
rails db:migrate
```
4. (Optional) seed the database

This will add 3 users of format user1/2/3@example.com with password password1/2/3. With some listings.
```
rails db:seed
```
5. Start server
```
rails s
```

## API Documentation
- cURL Commands available at `curl_commands.md`
- Once server started, swagger documentation available at 
```
   http://localhost:3000/api-docs
```

## Test Suite
```
bundle exec rspec
```

## Running in a docker container
```
docker-compose up --build
```
or 
```
test-docker.sh
```
## Front end
Available at `http://localhost:3000` after startup

## Notes

- No functionality included around the messages table. It needed some form of specs either - it either needs a Thread ID, Booking ID or Other User ID column. Otherwise you can just have a mess of messages between multiple people about a RV Listing.

