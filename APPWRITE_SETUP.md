# Appwrite Database Setup Guide

This guide explains how to set up the Appwrite database for your Crypto Trading Bot.

## Overview

The trading bot uses Appwrite as its backend database with the following collections:

- **watchlist** - Symbols to monitor and trade
- **trades** - Historical trade records
- **algorithms** - Trading algorithm configurations
- **portfolios** - Current portfolio holdings
- **bot_configs** - Bot configuration settings

## Setup Methods

You have three options to set up the database:

### Method 1: Automated Setup Script (Recommended)

Use the provided shell script for automatic setup:

```bash
# Make the script executable
chmod +x setup_appwrite.sh

# Run the setup
./setup_appwrite.sh
```

The script will prompt you for:
- Appwrite endpoint (e.g., `http://localhost/v1`)
- Project ID
- API Key

### Method 2: Manual Setup via Appwrite Console

1. **Access Appwrite Console**
   - Navigate to `http://localhost` (or your Appwrite URL)
   - Log in to your Appwrite instance

2. **Create a Project**
   - Click "Create Project"
   - Name it "Crypto Trading Bot"
   - Note the Project ID

3. **Create Database**
   - Go to "Databases"
   - Click "Add Database"
   - Database ID: `crypto_trading`
   - Name: "Crypto Trading Database"

4. **Create Collections**

   For each collection below, create it with the specified attributes:

   #### Watchlist Collection
   - Collection ID: `watchlist`
   - Attributes:
     - `userId` (String, 255, required)
     - `symbol` (String, 50, required)
     - `targetBuy` (Float, optional)
     - `targetSell` (Float, optional)
     - `active` (Boolean, required, default: true)
     - `createdAt` (DateTime, required)
   - Indexes:
     - `userId_idx` (key on userId)
     - `symbol_idx` (key on symbol)
     - `active_idx` (key on active)
     - `userId_active_idx` (key on userId, active)

   #### Trades Collection
   - Collection ID: `trades`
   - Attributes:
     - `userId` (String, 255, required)
     - `symbol` (String, 50, required)
     - `side` (String, 10, required)
     - `quantity` (Float, required)
     - `price` (Float, required)
     - `totalValue` (Float, required)
     - `timestamp` (DateTime, required)
     - `algorithmName` (String, 100, required)
     - `orderId` (String, 255, required)
     - `status` (String, 50, required)
   - Indexes:
     - `userId_idx` (key on userId)
     - `symbol_idx` (key on symbol)
     - `timestamp_idx` (key on timestamp, DESC)
     - `userId_timestamp_idx` (key on userId, timestamp)
     - `orderId_idx` (key on orderId)

   #### Algorithms Collection
   - Collection ID: `algorithms`
   - Attributes:
     - `userId` (String, 255, required)
     - `name` (String, 100, required)
     - `type` (String, 50, required)
     - `active` (Boolean, required, default: true)
     - `parameters` (String, 10000, optional)
     - `performance` (String, 10000, optional)
     - `createdAt` (DateTime, required)
     - `updatedAt` (DateTime, required)
   - Indexes:
     - `userId_idx` (key on userId)
     - `type_idx` (key on type)
     - `active_idx` (key on active)

   #### Portfolios Collection
   - Collection ID: `portfolios`
   - Attributes:
     - `userId` (String, 255, required)
     - `symbol` (String, 50, required)
     - `quantity` (Float, required)
     - `averagePrice` (Float, required)
     - `totalInvested` (Float, required)
     - `currentValue` (Float, optional)
     - `profitLoss` (Float, optional)
     - `profitLossPercent` (Float, optional)
     - `lastUpdated` (DateTime, required)
   - Indexes:
     - `userId_idx` (key on userId)
     - `symbol_idx` (key on symbol)
     - `userId_symbol_idx` (unique on userId, symbol)

   #### Bot Configurations Collection
   - Collection ID: `bot_configs`
   - Attributes:
     - `userId` (String, 255, required)
     - `botEnabled` (Boolean, required, default: false)
     - `simulationMode` (Boolean, required, default: true)
     - `checkIntervalSeconds` (Integer, required, min: 10, max: 3600, default: 30)
     - `maxPositionSize` (Float, required, min: 0.01, max: 1.0, default: 0.1)
     - `maxDailyLoss` (Float, required, min: 0.01, max: 0.5, default: 0.05)
     - `maxOpenPositions` (Integer, required, min: 1, max: 20, default: 5)
     - `stopLossPercent` (Float, required, min: 0.001, max: 0.5, default: 0.02)
     - `takeProfitPercent` (Float, required, min: 0.001, max: 1.0, default: 0.05)
     - `enableTrailingStop` (Boolean, required, default: true)
     - `trailingStopPercent` (Float, optional, min: 0.001, max: 0.5, default: 0.02)
     - `updatedAt` (DateTime, required)
   - Indexes:
     - `userId_idx` (unique on userId)

5. **Set Permissions**
   For each collection, set the following permissions:
   - Read: `any`
   - Create: `any`
   - Update: `any`
   - Delete: `any`

   **Note**: In production, you should restrict these to authenticated users only.

6. **Generate API Key**
   - Go to "Settings" → "API Keys"
   - Create a new API key with permissions to read/write to all collections
   - Copy the API key for your `.env` file

### Method 3: Appwrite CLI

If you prefer using the Appwrite CLI directly:

```bash
# Install Appwrite CLI
npm install -g appwrite-cli

# Login
appwrite login

# Deploy using the configuration
appwrite deploy collection

# Follow the prompts to select your project
```

## Environment Configuration

After setting up the database, update your `.env` file:

```bash
# Appwrite Configuration
APPWRITE_ENDPOINT=http://localhost/v1
APPWRITE_PROJECT_ID=your_project_id_here
APPWRITE_API_KEY=your_api_key_here
APPWRITE_DATABASE_ID=crypto_trading
APPWRITE_COLLECTION_WATCHLIST=watchlist
APPWRITE_COLLECTION_TRADES=trades
APPWRITE_COLLECTION_ALGORITHMS=algorithms
APPWRITE_COLLECTION_PORTFOLIOS=portfolios
APPWRITE_COLLECTION_BOT_CONFIGS=bot_configs
```

## Verification

To verify your setup is working:

1. **Check Database Connection**
   ```bash
   # Start just the API server
   cd api_server
   dart run bin/server.dart
   ```

2. **Test API Endpoints**
   ```bash
   # Health check
   curl http://localhost:3000/health

   # Get watchlist (should return empty array)
   curl http://localhost:3000/watchlist/default_user
   ```

3. **Add Test Data**
   ```bash
   # Add a symbol to watchlist
   curl -X POST http://localhost:3000/watchlist \
     -H "Content-Type: application/json" \
     -d '{
       "userId": "default_user",
       "symbol": "BTCUSDT",
       "active": true
     }'
   ```

## Troubleshooting

### Connection Errors

If you get connection errors:

1. Check Appwrite is running:
   ```bash
   docker-compose ps
   ```

2. Verify the endpoint in `.env` matches your Appwrite instance

3. Check API key permissions in Appwrite Console

### Permission Errors

If you get permission errors:

1. Go to Appwrite Console → Databases → [Collection]
2. Click "Settings" → "Permissions"
3. Add permissions for `any` role (or specific user roles)

### Collection Not Found

If collections are not found:

1. Verify the collection IDs in `.env` match exactly
2. Check the database ID is correct: `crypto_trading`
3. Ensure all collections were created successfully

## Database Schema Reference

### Watchlist
Stores symbols to monitor and trade.

```json
{
  "userId": "default_user",
  "symbol": "BTCUSDT",
  "targetBuy": 90000.0,
  "targetSell": 100000.0,
  "active": true,
  "createdAt": "2025-01-01T00:00:00.000Z"
}
```

### Trades
Records all executed trades.

```json
{
  "userId": "default_user",
  "symbol": "BTCUSDT",
  "side": "BUY",
  "quantity": 0.001,
  "price": 95000.0,
  "totalValue": 95.0,
  "timestamp": "2025-01-01T12:00:00.000Z",
  "algorithmName": "SMA Crossover",
  "orderId": "12345678",
  "status": "FILLED"
}
```

### Portfolios
Current holdings for each user.

```json
{
  "userId": "default_user",
  "symbol": "BTCUSDT",
  "quantity": 0.01,
  "averagePrice": 94500.0,
  "totalInvested": 945.0,
  "currentValue": 950.0,
  "profitLoss": 5.0,
  "profitLossPercent": 0.529,
  "lastUpdated": "2025-01-01T12:00:00.000Z"
}
```

### Bot Configurations
Per-user bot settings.

```json
{
  "userId": "default_user",
  "botEnabled": true,
  "simulationMode": true,
  "checkIntervalSeconds": 30,
  "maxPositionSize": 0.1,
  "maxDailyLoss": 0.05,
  "maxOpenPositions": 5,
  "stopLossPercent": 0.02,
  "takeProfitPercent": 0.05,
  "enableTrailingStop": true,
  "trailingStopPercent": 0.02,
  "updatedAt": "2025-01-01T00:00:00.000Z"
}
```

## Next Steps

Once your database is set up:

1. Configure your `.env` file with the correct credentials
2. Start the complete platform: `docker-compose up -d`
3. Access the web dashboard: `http://localhost:8080`
4. Add symbols to your watchlist
5. Monitor the bot logs: `docker-compose logs -f trading-bot`

## Security Best Practices

For production deployment:

1. **Restrict Permissions**
   - Remove `any` role permissions
   - Use authenticated user permissions
   - Implement role-based access control

2. **Use Environment Variables**
   - Never commit `.env` files to git
   - Use secrets management in production

3. **Enable SSL/TLS**
   - Use HTTPS for Appwrite endpoint
   - Configure SSL certificates

4. **Regular Backups**
   - Set up automated backups of your Appwrite database
   - Test restore procedures

5. **Monitor Access**
   - Review API logs regularly
   - Set up alerts for suspicious activity
