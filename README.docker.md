# Docker Setup for RV Marketplace

This guide explains how to run the RV Marketplace application using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose installed (usually comes with Docker Desktop)

## Quick Start

### Using Docker Compose (Recommended)

1. Build and start the application:
   ```bash
   docker-compose up --build
   ```

2. The application will be available at `http://localhost:3000`

3. To stop the application:
   ```bash
   docker-compose down
   ```

### Using Docker directly

1. Build the image:
   ```bash
   docker build -f Dockerfile.dev -t rv-marketplace:dev .
   ```

2. Run the container:
   ```bash
   docker run -p 3000:3000 \
     -v $(pwd):/app \
     -v bundle_cache:/usr/local/bundle \
     -e RAILS_ENV=development \
     rv-marketplace:dev \
     bash -c "rails db:create db:migrate db:seed && rails server -b 0.0.0.0"
   ```

## Database Setup

The docker-compose.yml automatically runs database migrations and seeds when starting the container. If you need to run migrations manually:

```bash
docker-compose exec web rails db:migrate
```

To reset the database:

```bash
docker-compose exec web rails db:reset
```

## Running Tests

To run the test suite inside the container:

```bash
docker-compose exec web bundle exec rspec
```

## Running Rails Console

To access the Rails console:

```bash
docker-compose exec web rails console
```

## Generating Swagger Documentation

To regenerate Swagger documentation:

```bash
docker-compose exec web bundle exec rake rswag:specs:swaggerize
```

## Troubleshooting

### Port already in use

If port 3000 is already in use, you can change it in `docker-compose.yml`:

```yaml
ports:
  - "3001:3000"  # Change 3001 to any available port
```

### Database issues

If you encounter database errors, try:

```bash
docker-compose down -v  # Remove volumes
docker-compose up --build
```

### View logs

To view application logs:

```bash
docker-compose logs -f web
```
