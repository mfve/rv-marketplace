# RV Marketplace API - cURL Commands

Base URL: `http://localhost:3000` (adjust as needed)

## Setup Variables
```zsh
export BASE_URL="http://localhost:3000"
export USER1_TOKEN=""
export USER2_TOKEN=""
export LISTING_ID=""
export BOOKING_ID=""
```
---

## 1. Authentication

### Sign Up - User 1
```zsh
curl -X POST "$BASE_URL/authenticate/sign_up" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Sign Up - User 2
```zsh
curl -X POST "$BASE_URL/authenticate/sign_up" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "password": "password123"
  }'
```

### Get Token - User 1
```zsh
# Run this command and copy the token from the response
curl -X POST "$BASE_URL/authenticate/token" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# Then export the token (replace YOUR_TOKEN_HERE with actual token):
# export USER1_TOKEN="YOUR_TOKEN_HERE"

# Or with jq:
# RESPONSE=$(curl -s -X POST "$BASE_URL/authenticate/token" -H "Content-Type: application/json" -d '{"email":"john@example.com","password":"password123"}')
# export USER1_TOKEN=$(echo "$RESPONSE" | jq -r '.token')
```

### Get Token - User 2
```zsh
# Run this command and copy the token from the response
curl -X POST "$BASE_URL/authenticate/token" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane@example.com",
    "password": "password123"
  }'

# Then export the token (replace YOUR_TOKEN_HERE with actual token):
# export USER2_TOKEN="YOUR_TOKEN_HERE"

# Or with jq:
# RESPONSE=$(curl -s -X POST "$BASE_URL/authenticate/token" -H "Content-Type: application/json" -d '{"email":"jane@example.com","password":"password123"}')
# export USER2_TOKEN=$(echo "$RESPONSE" | jq -r '.token')
```

### Invalid Credentials (Should Fail)
```zsh
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
```zsh
curl -X GET "$BASE_URL/listings" \
  -H "Content-Type: application/json"
```

### Show Listing (No Auth Required)
```zsh
curl -X GET "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json"
```

### Create Listing (Requires Auth)
```zsh
# Run this command and copy the ID from the response
curl -X POST "$BASE_URL/listings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER2_TOKEN" \
  -d '{
    "title": "Beautiful RV in the Mountains",
    "description": "A cozy RV perfect for weekend getaways",
    "location": "Newcastle, Australia",
    "price_per_day": "150.00"
  }'

# Then export the listing ID (replace YOUR_ID_HERE with actual ID):
# export LISTING_ID=YOUR_ID_HERE

# Or with jq:
# RESPONSE=$(curl -s -X POST "$BASE_URL/listings" -H "Content-Type: application/json" -H "Authorization: Bearer $USER1_TOKEN" -d '{"title":"Beautiful RV","description":"A cozy RV","location":"Aspen, CO","price_per_day":"150.00"}')
# export LISTING_ID=$(echo "$RESPONSE" | jq -r '.id')
```

### Update Listing (Requires Auth + Ownership)
```zsh
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
```zsh
curl -X DELETE "$BASE_URL/listings/$LISTING_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN"
```

### Update Other User's Listing (Should Fail - 403)
```zsh
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
  -H "Authorization: Bearer $USER2_TOKEN" \
  -d "{
    \"rv_listing_id\": $LISTING_ID,
    \"start_date\": \"2026-06-01\",
    \"end_date\": \"2026-06-05\"
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

```bash
curl -X POST "$BASE_URL/bookings/$BOOKING_ID/confirm" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER1_TOKEN"
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

1. Set base URL: `export BASE_URL="http://localhost:3000"`
2. Sign up User 1 → Get token → `export USER1_TOKEN="your_token_here"`
3. Sign up User 2 → Get token → `export USER2_TOKEN="your_token_here"`
4. Create listing as User 1 → `export LISTING_ID=1`
5. Create booking as User 1 for User 2's listing → `export BOOKING_ID=1`
6. List bookings as User 1 (should see booking)
7. List bookings as User 2 (should see listing_booking)
8. Confirm/reject booking as User 2 (listing owner)
