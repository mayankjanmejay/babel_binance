# Multi-stage Dockerfile for Dart trading bot
# Stage 1: Build
FROM dart:3.2 AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy source code
COPY . .

# Compile to native executable for better performance
RUN dart compile exe bin/server.dart -o trading_bot

# Stage 2: Runtime
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create app directory and user
RUN useradd -m -u 1000 bot && \
    mkdir -p /app /var/log && \
    chown -R bot:bot /app /var/log

WORKDIR /app

# Copy compiled binary from build stage
COPY --from=build --chown=bot:bot /app/trading_bot /app/trading_bot

# Copy .env.example (you'll mount the real .env)
COPY --chown=bot:bot .env.example /app/.env.example

# Switch to non-root user
USER bot

# Health check
HEALTHCHECK --interval=5m --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Expose health check port
EXPOSE 8080

# Run the bot
CMD ["/app/trading_bot"]
