# Multi-stage Dockerfile for API Server
FROM dart:3.2 AS build

WORKDIR /app

# Copy pubspec
COPY pubspec.* ./
RUN dart pub get

# Copy source
COPY . .

# Compile to native
RUN dart compile exe bin/server.dart -o api_server

# Runtime
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 api && \
    mkdir -p /app

WORKDIR /app

COPY --from=build --chown=api:api /app/api_server /app/api_server

USER api

HEALTHCHECK --interval=2m --timeout=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["/app/api_server"]
