# RV Marketplace API - cURL Commands

Base URL: `http://localhost:3000` (adjust as needed)

## Setup Variables
```bash
BASE_URL="http://localhost:3000"
# After running sign_up/token commands, extract tokens:
USER1_TOKEN="your_token_here"
USER2_TOKEN="your_token_here"
LISTING_ID=1
BOOKING_ID=1
```

---

## 1. Authentication

### Sign Up - User 1
```bash
curl -X POST "$BASE_URL/authenticate/sign_up" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Sign Up - User 2
```bash
curl -X POST "$BASE_URL/authenticate/sign_up" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "password": "password123"
  }'
```

### Get Token - User 1
```bash
curl -X POST "$BASE_URL/authenticate/token" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Get Token - User 2
```bash
curl -X POST "$BASE_URL/authenticate/token" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane@example.com",
    "password": "password123"
  }'
```

### Invalid Credentials (Should Fail)
```bash
curl -X POST "$BASE_URL/authenticate/token" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }'
```

---

## 2. Listings

### List All Listings (No Auth Required)
```bash
curl -X GET "$BASE_URL/listings" \
  -H "Content-Type: application/json"
```

### Show Listing (No Auth Required)
```bash
curl -X GET "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json"
```

### Create Listing (Requires Auth)
```bash
curl -X POST "$BASE_URL/listings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d '{
    "title": "Beautiful RV in the Mountains",
    "description": "A cozy RV perfect for weekend getaways",
    "location": "Aspen, CO",
    "price_per_day": "150.00"
  }'
```

### Update Listing (Requires Auth + Ownership)
```bash
curl -X PUT "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d '{
    "title": "Updated RV Title",
    "description": "Updated description",
    "location": "Updated Location",
    "price_per_day": "175.00"
  }'
```

### Delete Listing (Requires Auth + Ownership)
```bash
curl -X DELETE "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN"
```

### Update Other User's Listing (Should Fail - 403)
```bash
curl -X PUT "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN" \
  -d '{
    "title": "Hacked Title",
    "price_per_day": "1.00"
  }'
```

---

## 3. Bookings

### List Bookings (Requires Auth)
```bash
curl -X GET "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN"
```

### Create Booking (Requires Auth)
```bash
curl -X POST "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"2024-06-01\",
    \"end_date\": \"2024-06-05\"
  }"
```

### Create Booking - Invalid Date Format (Should Fail)
```bash
curl -X POST "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"invalid-date\",
    \"end_date\": \"2024-06-05\"
  }"
```

### Create Booking - End Before Start (Should Fail)
```bash
curl -X POST "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"2024-06-10\",
    \"end_date\": \"2024-06-05\"
  }"
```

### Create Booking - Past Date (Should Fail)
```bash
curl -X POST "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"2020-01-01\",
    \"end_date\": \"2020-01-05\"
  }"
```

### Create Booking - Own Listing (Should Fail)
```bash
curl -X POST "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"2024-07-01\",
    \"end_date\": \"2024-07-05\"
  }"
```

### Confirm Booking
**Note:** If your routes use member routes, use: `POST /bookings/:id/confirm`
If not, you may need to update routes to:
```ruby
resources :bookings, only: [:index, :create] do
  member do
    post :confirm
    post :reject
  end
end
```

```bash
curl -X POST "$BASE_URL/bookings/$BOOKING_ID/confirm" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN"
```

### Reject Booking
```bash
curl -X POST "$BASE_URL/bookings/$BOOKING_ID/reject" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN"
```

---

## 4. Error Cases

### Invalid Token
```bash
curl -X GET "$BASE_URL/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here"
```

### Missing Token
```bash
curl -X GET "$BASE_URL/bookings" \
  -H "Content-Type: application/json"
```

### Non-existent Listing
```bash
curl -X GET "$BASE_URL/listings/99999" \
  -H "Content-Type: application/json"
```

### Non-existent Booking
```bash
curl -X POST "$BASE_URL/bookings/99999/confirm" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN"
```

---

## Quick Test Sequence

1. Sign up User 1 → Get token → Store as `USER1_TOKEN`
2. Sign up User 2 → Get token → Store as `USER2_TOKEN`
3. Create listing as User 1 → Store ID as `LISTING_ID`
4. Create booking as User 1 for User 2's listing → Store ID as `BOOKING_ID`
5. List bookings as User 1 (should see booking)
6. List bookings as User 2 (should see listing_booking)
7. Confirm/reject booking as User 2 (listing owner)

---

## Note on Routes

If `confirm` and `reject` don't work as `/bookings/:id/confirm`, update your routes.rb:

```ruby
resources :bookings, only: [:index, :create] do
  member do
    post :confirm
    post :reject
  end
end
```

This will create:
- `POST /bookings/:id/confirm`
- `POST /bookings/:id/reject`
