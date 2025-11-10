#!/bin/bash

# Script to set up Appwrite database collections for the trading bot

echo "🚀 Setting up Appwrite database for Crypto Trading Bot"

# Configuration
APPWRITE_ENDPOINT="${APPWRITE_ENDPOINT:-http://localhost/v1}"
APPWRITE_PROJECT_ID="${APPWRITE_PROJECT_ID}"
APPWRITE_API_KEY="${APPWRITE_API_KEY}"
DATABASE_ID="crypto_trading"

# Check if appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo "❌ Appwrite CLI not found. Installing..."
    npm install -g appwrite-cli
fi

# Login to Appwrite
echo "📝 Logging in to Appwrite..."
appwrite client --endpoint "$APPWRITE_ENDPOINT" --projectId "$APPWRITE_PROJECT_ID" --key "$APPWRITE_API_KEY"

# Create database
echo "🗄️  Creating database: $DATABASE_ID"
appwrite databases create --databaseId "$DATABASE_ID" --name "Crypto Trading" || echo "Database already exists"

# Create watchlist collection
echo "📋 Creating 'watchlist' collection..."
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "watchlist" \
    --name "Watchlist" \
    --permissions 'read("any")' 'create("any")' 'update("any")' 'delete("any")' || echo "Collection already exists"

# Add watchlist attributes
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "user_id" --size 255 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "symbol" --size 20 --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "target_buy" --required false
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "target_sell" --required false
appwrite databases createBooleanAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "active" --required true --default true
appwrite databases createDatetimeAttribute --databaseId "$DATABASE_ID" --collectionId "watchlist" --key "created_at" --required true

# Create trades collection
echo "💰 Creating 'trades' collection..."
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "trades" \
    --name "Trades" \
    --permissions 'read("any")' 'create("any")' || echo "Collection already exists"

# Add trades attributes
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "user_id" --size 255 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "symbol" --size 20 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "side" --size 10 --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "quantity" --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "price" --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "total_value" --required true
appwrite databases createDatetimeAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "timestamp" --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "algorithm_name" --size 100 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "order_id" --size 100 --required false
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "trades" --key "status" --size 20 --required true

# Create portfolios collection
echo "📊 Creating 'portfolios' collection..."
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "portfolios" \
    --name "Portfolios" \
    --permissions 'read("any")' 'create("any")' 'update("any")' || echo "Collection already exists"

# Add portfolios attributes
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "portfolios" --key "user_id" --size 255 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "portfolios" --key "asset" --size 20 --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "portfolios" --key "quantity" --required true
appwrite databases createFloatAttribute --databaseId "$DATABASE_ID" --collectionId "portfolios" --key "avg_buy_price" --required true
appwrite databases createDatetimeAttribute --databaseId "$DATABASE_ID" --collectionId "portfolios" --key "updated_at" --required true

# Create algorithms collection
echo "🤖 Creating 'algorithms' collection..."
appwrite databases createCollection \
    --databaseId "$DATABASE_ID" \
    --collectionId "algorithms" \
    --name "Algorithms" \
    --permissions 'read("any")' 'create("any")' 'update("any")' || echo "Collection already exists"

# Add algorithms attributes
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "algorithms" --key "user_id" --size 255 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "algorithms" --key "name" --size 100 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "algorithms" --key "type" --size 50 --required true
appwrite databases createStringAttribute --databaseId "$DATABASE_ID" --collectionId "algorithms" --key "params" --size 1000 --required true
appwrite databases createBooleanAttribute --databaseId "$DATABASE_ID" --collectionId "algorithms" --key "active" --required true --default true

echo "✅ Appwrite database setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Add symbols to watchlist manually or via API"
echo "2. Update .env with your configuration"
echo "3. Start the trading bot: docker-compose up -d"
