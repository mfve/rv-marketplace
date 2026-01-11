#!/bin/bash

# Test script for Docker setup
set -e

echo "🐳 Testing Docker setup for RV Marketplace..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Build the image
echo "📦 Building Docker image..."
docker-compose build

echo ""
echo "🚀 Starting containers..."
docker-compose up -d

echo ""
echo "⏳ Waiting for application to start..."
sleep 10

# Check if the application is responding
echo ""
echo "🔍 Checking if application is responding..."
if curl -f http://localhost:3000/up > /dev/null 2>&1; then
    echo "✅ Application is running at http://localhost:3000"
else
    echo "❌ Application is not responding. Check logs with: docker-compose logs"
    docker-compose logs --tail=50
    exit 1
fi

echo ""
echo "📋 Container status:"
docker-compose ps

echo ""
echo "✅ Docker setup test completed successfully!"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo "To access console: docker-compose exec web rails console"
