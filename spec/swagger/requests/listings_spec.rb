# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Listings API", type: :request do
  let(:user) { create(:user) }
  let(:token) { Devise::Api::TokensService::Create.new(resource_owner: user).call.value! }
  let(:auth_header) { { "Authorization" => "Bearer #{token.access_token}" } }

  path "/listings" do
    get "List all listings" do
      tags "Listings"
      produces "application/json"

      response "200", "Listings retrieved successfully" do
        schema type: :object,
               properties: {
                 listings: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       title: { type: :string, example: "Beautiful RV in the Mountains" },
                       description: { type: :string, example: "A cozy RV perfect for weekend getaways" },
                       location: { type: :string, example: "Melbourne, VIC" },
                       price_per_day: { type: :number, example: 150.00 }
                     }
                   }
                 }
               }

        let!(:listing1) { create(:rv_listing) }
        let!(:listing2) { create(:rv_listing) }

        run_test!
      end
    end

    post "Create a new listing" do
      tags "Listings"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :listing, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Beautiful RV in the Mountains" },
          description: { type: :string, example: "A cozy RV perfect for weekend getaways" },
          location: { type: :string, example: "Melbourne, VIC" },
          price_per_day: { type: :number, example: 150.00 }
        },
        required: [ "title", "description", "location", "price_per_day" ]
      }

      response "201", "Listing created successfully" do
        schema type: :object,
               properties: {
                 listing: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: "Beautiful RV in the Mountains" },
                     description: { type: :string, example: "A cozy RV perfect for weekend getaways" },
                     location: { type: :string, example: "Melbourne, VIC" },
                     price_per_day: { type: :number, example: 150.00 }
                   }
                 }
               }

        let(:listing) do
          {
            title: "Beautiful RV in the Mountains",
            description: "A cozy RV perfect for weekend getaways",
            location: "Melbourne, VIC",
            price_per_day: 150.00
          }
        end

        let(:Authorization) { auth_header["Authorization"] }
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

        let(:listing) do
          {
            title: "Beautiful RV",
            description: "A cozy RV",
            location: "Melbourne, VIC",
            price_per_day: 150.00
          }
        end

        let(:Authorization) { nil }
        run_test!
      end

      response "422", "Validation errors" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Title can't be blank", "Price per day must be greater than 0" ]
                 }
               }

        let(:listing) { { title: "" } }
        let(:Authorization) { auth_header["Authorization"] }
        run_test!
      end
    end
  end

  path "/listings/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true, description: "Listing ID"

    get "Get a specific listing" do
      tags "Listings"
      produces "application/json"

      response "200", "Listing retrieved successfully" do
        schema type: :object,
               properties: {
                 listing: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: "Beautiful RV in the Mountains" },
                     description: { type: :string, example: "A cozy RV perfect for weekend getaways" },
                     location: { type: :string, example: "Melbourne, VIC" },
                     price_per_day: { type: :number, example: 150.00 }
                   }
                 }
               }

        let(:id) { create(:rv_listing).id }
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

        let(:id) { 99999 }
        run_test!
      end
    end

    put "Update a listing" do
      tags "Listings"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :listing, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Updated RV Title" },
          description: { type: :string, example: "Updated description" },
          location: { type: :string, example: "Updated Location" },
          price_per_day: { type: :number, example: 175.00 }
        }
      }

      response "200", "Listing updated successfully" do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 title: { type: :string, example: "Updated RV Title" },
                 description: { type: :string, example: "Updated description" },
                 location: { type: :string, example: "Updated Location" },
                 price_per_day: { type: :number, example: 175.00 }
               }

        let(:id) { create(:rv_listing, user: user).id }
        let(:listing) { { title: "Updated RV Title" } }
        let(:Authorization) { auth_header["Authorization"] }
        run_test!
      end

      response "403", "Forbidden - not the owner" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Forbidden to update other users listings" ]
                 }
               }

        let(:other_user) { create(:user) }
        let(:id) { create(:rv_listing, user: other_user).id }
        let(:listing) { { title: "Updated Title" } }
        let(:Authorization) { auth_header["Authorization"] }
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

        let(:id) { 99999 }
        let(:listing) { { title: "Updated Title" } }
        let(:Authorization) { auth_header["Authorization"] }
        run_test!
      end
    end

    delete "Delete a listing" do
      tags "Listings"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "204", "Listing deleted successfully" do
        let(:id) { create(:rv_listing, user: user).id }
        let(:Authorization) { auth_header["Authorization"] }
        run_test!
      end

      response "403", "Forbidden - not the owner" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Forbidden to update other users listings" ]
                 }
               }

        let(:other_user) { create(:user) }
        let(:id) { create(:rv_listing, user: other_user).id }
        let(:Authorization) { auth_header["Authorization"] }
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

        let(:id) { 99999 }
        let(:Authorization) { auth_header["Authorization"] }
        run_test!
      end
    end
  end
end
