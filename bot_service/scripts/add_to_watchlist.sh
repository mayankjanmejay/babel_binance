#!/bin/bash

# Quick script to add symbols to watchlist via curl
# Usage: ./add_to_watchlist.sh BTCUSDT

APPWRITE_ENDPOINT="${APPWRITE_ENDPOINT:-http://localhost/v1}"
APPWRITE_PROJECT_ID="${APPWRITE_PROJECT_ID}"
APPWRITE_API_KEY="${APPWRITE_API_KEY}"
DATABASE_ID="crypto_trading"
COLLECTION_ID="watchlist"
USER_ID="${BOT_USER_ID:-default_user}"

SYMBOL="${1:-BTCUSDT}"

echo "Adding $SYMBOL to watchlist..."

curl -X POST "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/documents" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    -d "{
        \"documentId\": \"unique()\",
        \"data\": {
            \"user_id\": \"$USER_ID\",
            \"symbol\": \"$SYMBOL\",
            \"active\": true,
            \"created_at\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\"
        }
    }"

echo ""
echo "✅ Added $SYMBOL to watchlist"
