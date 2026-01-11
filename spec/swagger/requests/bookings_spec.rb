# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Bookings API", type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:rv_listing) { create(:rv_listing, user: user2) }

  let(:token1) { Devise::Api::TokensService::Create.new(resource_owner: user1).call.value! }
  let(:auth_header1) { { "Authorization" => "Bearer #{token1.access_token}" } }

  let(:token2) { Devise::Api::TokensService::Create.new(resource_owner: user2).call.value! }
  let(:auth_header2) { { "Authorization" => "Bearer #{token2.access_token}" } }

  path "/bookings" do
    get "Get all bookings for the current user" do
      tags "Bookings"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "Bookings retrieved successfully" do
        schema type: :object,
               properties: {
                 bookings: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       start_date: { type: :string, format: :date, example: "2024-01-15" },
                       end_date: { type: :string, format: :date, example: "2024-01-20" },
                       status: { type: :string, example: "pending", enum: [ "pending", "confirmed", "rejected" ] }
                     }
                   }
                 },
                 listing_bookings: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       start_date: { type: :string, format: :date, example: "2024-01-15" },
                       end_date: { type: :string, format: :date, example: "2024-01-20" },
                       status: { type: :string, example: "pending", enum: [ "pending", "confirmed", "rejected" ] }
                     }
                   }
                 }
               }

        let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing) }
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end

      response "401", "Unauthorized" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Unauthorized" ]
                 }
               }

        let(:Authorization) { nil }
        run_test!
      end
    end

    post "Create a new booking" do
      tags "Bookings"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          rv_listing_id: { type: :integer, example: 1 },
          start_date: { type: :string, format: :date, example: "2024-01-15" },
          end_date: { type: :string, format: :date, example: "2024-01-20" }
        },
        required: [ "rv_listing_id", "start_date", "end_date" ]
      }

      response "201", "Booking created successfully" do
        schema type: :object,
               properties: {
                 booking: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     start_date: { type: :string, format: :date, example: "2024-01-15" },
                     end_date: { type: :string, format: :date, example: "2024-01-20" },
                     status: { type: :string, example: "pending" }
                   }
                 }
               }

        let(:booking) do
          {
            rv_listing_id: rv_listing.id,
            start_date: (Date.today + 7.days).to_s,
            end_date: (Date.today + 10.days).to_s
          }
        end
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end

      response "401", "Unauthorized" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Unauthorized" ]
                 }
               }

        let(:booking) do
          {
            rv_listing_id: rv_listing.id,
            start_date: (Date.today + 7.days).to_s,
            end_date: (Date.today + 10.days).to_s
          }
        end
        let(:Authorization) { nil }
        run_test!
      end

      response "404", "Listing not found" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Listing not found" ]
                 }
               }

        let(:booking) do
          {
            rv_listing_id: 99999,
            start_date: (Date.today + 7.days).to_s,
            end_date: (Date.today + 10.days).to_s
          }
        end
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end

      response "422", "Validation errors" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "You cannot book your own listing", "Invalid date format. Use YYYY-MM-DD" ]
                 }
               }

        let(:own_listing) { create(:rv_listing, user: user1) }
        let(:booking) do
          {
            rv_listing_id: own_listing.id,
            start_date: (Date.today + 7.days).to_s,
            end_date: (Date.today + 10.days).to_s
          }
        end
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end
    end
  end

  path "/bookings/{id}/confirm" do
    parameter name: :id, in: :path, type: :integer, required: true, description: "Booking ID"

    post "Confirm a booking" do
      tags "Bookings"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "Booking confirmed successfully" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Booking confirmed" }
               }

        let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: "pending") }
        let(:id) { booking.id }
        let(:Authorization) { auth_header2["Authorization"] }
        run_test!
      end

      response "404", "Booking not found or forbidden" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Booking not found or forbidden" ]
                 }
               }

        let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: "pending") }
        let(:id) { booking.id }
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end
    end
  end

  path "/bookings/{id}/reject" do
    parameter name: :id, in: :path, type: :integer, required: true, description: "Booking ID"

    post "Reject a booking" do
      tags "Bookings"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "Booking rejected successfully" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Booking rejected" }
               }

        let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: "pending") }
        let(:id) { booking.id }
        let(:Authorization) { auth_header2["Authorization"] }
        run_test!
      end

      response "404", "Booking not found or forbidden" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Booking not found or forbidden" ]
                 }
               }

        let!(:booking) { create(:booking, user: user1, rv_listing: rv_listing, status: "pending") }
        let(:id) { booking.id }
        let(:Authorization) { auth_header1["Authorization"] }
        run_test!
      end
    end
  end
end
