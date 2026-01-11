# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  path "/authenticate/sign_up" do
    post "Sign up a new user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "John Doe" },
          email: { type: :string, example: "john@example.com" },
          password: { type: :string, example: "password123" },
          password_confirmation: { type: :string, example: "password123" }
        },
        required: [ "email", "password", "password_confirmation" ]
      }

      response "201", "User created successfully" do
        schema type: :object,
               properties: {
                 token: { type: :string, example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." },
                 expires_in: { type: :integer, example: 3600 }
               }

        let(:user) do
          {
            name: "John Doe",
            email: "john@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test!
      end

      response "422", "Invalid parameters" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Email has already been taken", "Password is too short" ]
                 }
               }

        let(:user) { { email: "invalid" } }
        run_test!
      end
    end
  end

  path "/authenticate/token" do
    post "Get authentication token" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "john@example.com" },
          password: { type: :string, example: "password123" }
        },
        required: [ "email", "password" ]
      }

      response "200", "Token generated successfully" do
        schema type: :object,
               properties: {
                 token: { type: :string, example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." },
                 expires_in: { type: :integer, example: 3600 }
               }

        let!(:user) { create(:user, email: "john@example.com", password: "password123") }
        let(:credentials) do
          {
            email: "john@example.com",
            password: "password123"
          }
        end

        run_test!
      end

      response "401", "Invalid credentials" do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: [ "Invalid email or password" ]
                 }
               }

        let(:credentials) do
          {
            email: "john@example.com",
            password: "wrongpassword"
          }
        end

        run_test!
      end
    end
  end
end
