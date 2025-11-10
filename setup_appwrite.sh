#!/bin/bash

# Appwrite Database Setup Script
# This script creates the database and all collections for the crypto trading bot

set -e

echo "🚀 Crypto Trading Bot - Appwrite Setup"
echo "========================================"
echo ""

# Check if Appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo "❌ Appwrite CLI is not installed"
    echo ""
    echo "Please install it first:"
    echo "  npm install -g appwrite-cli"
    echo "  or"
    echo "  brew install appwrite"
    echo ""
    exit 1
fi

echo "✅ Appwrite CLI found"
echo ""

# Check if appwrite.json exists
if [ ! -f "appwrite.json" ]; then
    echo "❌ appwrite.json not found in current directory"
    exit 1
fi

echo "📋 Configuration file found"
echo ""

# Prompt for Appwrite endpoint
read -p "Enter your Appwrite endpoint (default: http://localhost/v1): " APPWRITE_ENDPOINT
APPWRITE_ENDPOINT=${APPWRITE_ENDPOINT:-http://localhost/v1}

# Prompt for Project ID
read -p "Enter your Appwrite Project ID: " PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Project ID is required"
    exit 1
fi

# Prompt for API Key
read -sp "Enter your Appwrite API Key: " API_KEY
echo ""
if [ -z "$API_KEY" ]; then
    echo "❌ API Key is required"
    exit 1
fi

echo ""
echo "🔧 Configuring Appwrite CLI..."
appwrite client --endpoint "$APPWRITE_ENDPOINT"
appwrite client --key "$API_KEY"

echo ""
echo "📦 Creating database: crypto_trading..."

# Create database
appwrite databases create \
    --databaseId "crypto_trading" \
    --name "Crypto Trading Database"

echo "✅ Database created"
echo ""

# Function to create a collection
create_collection() {
    local COLLECTION_ID=$1
    local COLLECTION_NAME=$2

    echo "📝 Creating collection: $COLLECTION_NAME ($COLLECTION_ID)..."

    appwrite databases createCollection \
        --databaseId "crypto_trading" \
        --collectionId "$COLLECTION_ID" \
        --name "$COLLECTION_NAME" \
        --permissions 'read("any")' 'create("any")' 'update("any")' 'delete("any")' \
        --documentSecurity true

    echo "✅ Collection created: $COLLECTION_NAME"
}

# Create all collections
create_collection "watchlist" "Watchlist"
create_collection "trades" "Trades"
create_collection "algorithms" "Algorithms"
create_collection "portfolios" "Portfolios"
create_collection "bot_configs" "Bot Configurations"

echo ""
echo "🏗️  Creating collection attributes..."
echo ""

# Watchlist attributes
echo "📊 Setting up Watchlist collection..."
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "userId" --size 255 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "symbol" --size 50 --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "targetBuy" --required false
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "targetSell" --required false
appwrite databases createBooleanAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "active" --required true --default true
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "watchlist" --key "createdAt" --required true

echo "✅ Watchlist attributes created"
echo ""

# Trades attributes
echo "📊 Setting up Trades collection..."
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "userId" --size 255 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "symbol" --size 50 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "side" --size 10 --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "trades" --key "quantity" --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "trades" --key "price" --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "trades" --key "totalValue" --required true
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "trades" --key "timestamp" --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "algorithmName" --size 100 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "orderId" --size 255 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "trades" --key "status" --size 50 --required true

echo "✅ Trades attributes created"
echo ""

# Algorithms attributes
echo "📊 Setting up Algorithms collection..."
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "userId" --size 255 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "name" --size 100 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "type" --size 50 --required true
appwrite databases createBooleanAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "active" --required true --default true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "parameters" --size 10000 --required false
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "performance" --size 10000 --required false
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "createdAt" --required true
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "algorithms" --key "updatedAt" --required true

echo "✅ Algorithms attributes created"
echo ""

# Portfolios attributes
echo "📊 Setting up Portfolios collection..."
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "userId" --size 255 --required true
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "symbol" --size 50 --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "quantity" --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "averagePrice" --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "totalInvested" --required true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "currentValue" --required false
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "profitLoss" --required false
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "profitLossPercent" --required false
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "portfolios" --key "lastUpdated" --required true

echo "✅ Portfolios attributes created"
echo ""

# Bot Configs attributes
echo "📊 Setting up Bot Configurations collection..."
appwrite databases createStringAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "userId" --size 255 --required true
appwrite databases createBooleanAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "botEnabled" --required true --default false
appwrite databases createBooleanAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "simulationMode" --required true --default true
appwrite databases createIntegerAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "checkIntervalSeconds" --required true --min 10 --max 3600 --default 30
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "maxPositionSize" --required true --min 0.01 --max 1.0 --default 0.1
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "maxDailyLoss" --required true --min 0.01 --max 0.5 --default 0.05
appwrite databases createIntegerAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "maxOpenPositions" --required true --min 1 --max 20 --default 5
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "stopLossPercent" --required true --min 0.001 --max 0.5 --default 0.02
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "takeProfitPercent" --required true --min 0.001 --max 1.0 --default 0.05
appwrite databases createBooleanAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "enableTrailingStop" --required true --default true
appwrite databases createFloatAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "trailingStopPercent" --required false --min 0.001 --max 0.5 --default 0.02
appwrite databases createDatetimeAttribute --databaseId "crypto_trading" --collectionId "bot_configs" --key "updatedAt" --required true

echo "✅ Bot Configurations attributes created"
echo ""

echo "⏳ Waiting for attributes to be ready (this may take a few moments)..."
sleep 10

echo ""
echo "🔍 Creating indexes for better performance..."
echo ""

# Watchlist indexes
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "watchlist" --key "userId_idx" --type "key" --attributes "userId" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "watchlist" --key "symbol_idx" --type "key" --attributes "symbol" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "watchlist" --key "active_idx" --type "key" --attributes "active" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "watchlist" --key "userId_active_idx" --type "key" --attributes "userId,active" --orders "ASC,ASC"

# Trades indexes
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "trades" --key "userId_idx" --type "key" --attributes "userId" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "trades" --key "symbol_idx" --type "key" --attributes "symbol" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "trades" --key "timestamp_idx" --type "key" --attributes "timestamp" --orders "DESC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "trades" --key "userId_timestamp_idx" --type "key" --attributes "userId,timestamp" --orders "ASC,DESC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "trades" --key "orderId_idx" --type "key" --attributes "orderId" --orders "ASC"

# Algorithms indexes
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "algorithms" --key "userId_idx" --type "key" --attributes "userId" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "algorithms" --key "type_idx" --type "key" --attributes "type" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "algorithms" --key "active_idx" --type "key" --attributes "active" --orders "ASC"

# Portfolios indexes
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "portfolios" --key "userId_idx" --type "key" --attributes "userId" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "portfolios" --key "symbol_idx" --type "key" --attributes "symbol" --orders "ASC"
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "portfolios" --key "userId_symbol_idx" --type "unique" --attributes "userId,symbol" --orders "ASC,ASC"

# Bot Configs indexes
appwrite databases createIndex --databaseId "crypto_trading" --collectionId "bot_configs" --key "userId_idx" --type "unique" --attributes "userId" --orders "ASC"

echo "✅ All indexes created"
echo ""
echo "🎉 Setup complete!"
echo ""
echo "Database: crypto_trading"
echo "Collections created:"
echo "  - watchlist"
echo "  - trades"
echo "  - algorithms"
echo "  - portfolios"
echo "  - bot_configs"
echo ""
echo "Next steps:"
echo "1. Update your .env file with:"
echo "   APPWRITE_ENDPOINT=$APPWRITE_ENDPOINT"
echo "   APPWRITE_PROJECT_ID=$PROJECT_ID"
echo "   APPWRITE_API_KEY=<your_api_key>"
echo "   APPWRITE_DATABASE_ID=crypto_trading"
echo ""
echo "2. Start the trading bot:"
echo "   docker-compose up -d"
echo ""
