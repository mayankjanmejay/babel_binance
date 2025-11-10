# 🤖 Crypto Trading Bot Service

A 24/7 automated cryptocurrency trading bot using the Binance API and Appwrite backend.

## 📋 Features

- ✅ **24/7 Automated Trading** - Runs continuously monitoring markets
- ✅ **Multiple Algorithms** - SMA Crossover, RSI Strategy, Grid Trading
- ✅ **Multi-Coin Support** - Watch and trade multiple cryptocurrency pairs
- ✅ **Simulation Mode** - Test strategies without risking real money
- ✅ **Appwrite Integration** - Persistent storage for trades and watchlist
- ✅ **Real-time Monitoring** - Health check endpoint for monitoring
- ✅ **Graceful Shutdown** - Clean shutdown on SIGINT/SIGTERM
- ✅ **Comprehensive Logging** - Console and file logging

## 🏗️ Architecture

```
Trading Bot
├── Main Loop (every 30s)
│   ├── Fetch current prices
│   ├── Run algorithms on each symbol
│   └── Execute trades when signals detected
│
├── Algorithms
│   ├── SMA Crossover (20/50 periods)
│   ├── RSI Strategy (oversold/overbought)
│   └── Grid Trading (multiple price levels)
│
├── Services
│   ├── Binance API (via babel_binance)
│   └── Appwrite (database storage)
│
└── Health Check Server (port 8080)
    └── GET /health - Returns bot statistics
```

## 📦 Installation

### Prerequisites

- Dart SDK 3.0+
- Docker & Docker Compose (for containerized deployment)
- Binance account with API keys
- Appwrite instance (see setup below)

### 1. Clone and Setup

```bash
cd bot_service
cp .env.example .env
```

### 2. Configure Environment Variables

Edit `.env` with your credentials:

```bash
# Binance API
BINANCE_API_KEY=your_binance_api_key
BINANCE_API_SECRET=your_binance_api_secret

# Appwrite
APPWRITE_ENDPOINT=http://localhost/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
APPWRITE_DATABASE_ID=crypto_trading

# Bot Configuration
BOT_SIMULATION_MODE=true  # IMPORTANT: Set to false for live trading
BOT_CHECK_INTERVAL_SECONDS=30
```

### 3. Setup Appwrite Database

Create the following collections in Appwrite:

#### Collection: `watchlist`
```json
{
  "user_id": "string (required)",
  "symbol": "string (required)",
  "target_buy": "float (optional)",
  "target_sell": "float (optional)",
  "active": "boolean (default: true)",
  "created_at": "datetime"
}
```

#### Collection: `trades`
```json
{
  "user_id": "string (required)",
  "symbol": "string (required)",
  "side": "string (required)",
  "quantity": "float (required)",
  "price": "float (required)",
  "total_value": "float (required)",
  "timestamp": "datetime",
  "algorithm_name": "string",
  "order_id": "string (optional)",
  "status": "string"
}
```

#### Collection: `portfolios`
```json
{
  "user_id": "string (required)",
  "asset": "string (required)",
  "quantity": "float",
  "avg_buy_price": "float",
  "updated_at": "datetime"
}
```

### 4. Add Coins to Watchlist

Add symbols to monitor via Appwrite console or API:

```dart
// Example: Add BTC, ETH, BNB to watchlist
final items = [
  {'user_id': 'default_user', 'symbol': 'BTCUSDT', 'active': true},
  {'user_id': 'default_user', 'symbol': 'ETHUSDT', 'active': true},
  {'user_id': 'default_user', 'symbol': 'BNBUSDT', 'active': true},
];
```

## 🚀 Running the Bot

### Method 1: Docker Compose (Recommended for 24/7)

```bash
# Build and start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f trading-bot

# Stop
docker-compose down
```

### Method 2: Direct with Dart

```bash
# Install dependencies
dart pub get

# Run the bot
dart run bin/server.dart
```

### Method 3: Compiled Executable

```bash
# Compile to native executable
dart compile exe bin/server.dart -o trading_bot

# Run
./trading_bot
```

### Method 4: Systemd Service (Linux Server)

```bash
# 1. Compile the bot
dart compile exe bin/server.dart -o trading_bot

# 2. Create installation directory
sudo mkdir -p /opt/trading-bot
sudo cp trading_bot .env /opt/trading-bot/
sudo mkdir -p /var/log/trading-bot

# 3. Create bot user
sudo useradd -r -s /bin/false bot
sudo chown -R bot:bot /opt/trading-bot /var/log/trading-bot

# 4. Install systemd service
sudo cp trading-bot.service /etc/systemd/system/
sudo systemctl daemon-reload

# 5. Enable and start
sudo systemctl enable trading-bot
sudo systemctl start trading-bot

# 6. Check status
sudo systemctl status trading-bot

# 7. View logs
sudo journalctl -u trading-bot -f
```

## 📊 Monitoring

### Health Check Endpoint

The bot exposes a health check endpoint on port 8080:

```bash
curl http://localhost:8080/health
```

Response:
```json
{
  "status": "healthy",
  "uptime_minutes": 120,
  "cycles_completed": 240,
  "trades_executed": 15,
  "errors_encountered": 0,
  "watchlist_size": 3,
  "active_algorithms": 3,
  "timestamp": "2025-11-10T12:30:00Z"
}
```

### Logs

**Docker:**
```bash
docker-compose logs -f trading-bot
```

**Systemd:**
```bash
sudo journalctl -u trading-bot -f
```

**File:**
```bash
tail -f /var/log/trading-bot.log
```

## ⚙️ Configuration

### Algorithm Parameters

Edit `bin/server.dart` to customize algorithms:

```dart
final algorithms = [
  SMACrossover(
    shortPeriod: 20,    // Fast moving average
    longPeriod: 50,     // Slow moving average
    quantity: 0.001,    // Amount to trade
  ),
  RSIStrategy(
    period: 14,         // RSI calculation period
    oversold: 30,       // Buy threshold
    overbought: 70,     // Sell threshold
    quantity: 0.001,
  ),
  GridTrading(
    lowerBound: 90000,  // Lower price bound
    upperBound: 100000, // Upper price bound
    gridLevels: 10,     // Number of grid levels
    quantityPerGrid: 0.0001,
  ),
];
```

### Enable/Disable Algorithms

```dart
// Disable an algorithm
algorithms[0].active = false;

// Or remove from list
final algorithms = [
  SMACrossover(...),
  // RSIStrategy(...),  // Commented out = disabled
];
```

## 🔒 Security Best Practices

1. **API Keys**
   - Never commit `.env` file to git
   - Use read-only Binance API keys when possible
   - Enable IP whitelist on Binance

2. **Simulation Mode**
   - Always test in simulation mode first
   - Set `BOT_SIMULATION_MODE=true` in `.env`
   - Monitor for several days before going live

3. **Risk Management**
   - Start with small quantities
   - Set stop-loss limits
   - Monitor daily loss limits
   - Never invest more than you can afford to lose

4. **Access Control**
   - Run bot as non-root user
   - Restrict file permissions: `chmod 600 .env`
   - Use firewall to restrict access

## 📈 Going Live (LIVE TRADING)

⚠️ **WARNING: Live trading involves real money. Proceed with caution!**

1. **Test Thoroughly**
   - Run in simulation mode for at least 1 week
   - Verify all algorithms work as expected
   - Check trade execution logs

2. **Start Small**
   - Begin with minimal quantities
   - Use only 1-5% of your portfolio
   - Monitor closely for first 24 hours

3. **Enable Live Trading**
   ```bash
   # In .env file
   BOT_SIMULATION_MODE=false
   BOT_ENABLE_TRADING=true
   ```

4. **Monitor Continuously**
   - Set up alerts for errors
   - Check health endpoint regularly
   - Review trade logs daily

## 🛠️ Troubleshooting

### Bot Not Starting

```bash
# Check logs
docker-compose logs trading-bot

# Verify environment variables
cat .env

# Test Appwrite connection
curl http://localhost/v1/health

# Test Binance API
curl https://api.binance.com/api/v3/time
```

### No Trades Executing

1. Check if watchlist is empty
2. Verify algorithms are active
3. Ensure simulation mode setting is correct
4. Check if market conditions meet algorithm criteria

### Connection Errors

```bash
# Restart services
docker-compose restart

# Check network
docker network ls
docker network inspect bot_service_trading-network

# Verify Appwrite is running
docker ps | grep appwrite
```

## 📚 Adding Custom Algorithms

Create a new file in `lib/algorithms/`:

```dart
import '../models/trade_signal.dart';
import 'trading_algorithm.dart';

class MyCustomAlgorithm extends TradingAlgorithm {
  MyCustomAlgorithm() : super(
    name: 'My Custom Algorithm',
    params: {'param1': 100},
  );

  @override
  Future<TradeSignal?> analyze(String symbol, double currentPrice) async {
    addPrice(symbol, currentPrice);

    // Your logic here
    if (/* buy condition */) {
      return TradeSignal(
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
        reason: 'Your reason',
        algorithmName: name,
      );
    }

    return null;
  }
}
```

Then add to `bin/server.dart`:

```dart
import '../lib/algorithms/my_custom_algorithm.dart';

final algorithms = [
  // ... existing algorithms
  MyCustomAlgorithm(),
];
```

## 🔄 Updates and Maintenance

### Updating the Bot

```bash
# Pull latest code
git pull

# Rebuild Docker image
docker-compose build

# Restart with new version
docker-compose up -d
```

### Database Backups

```bash
# Backup Appwrite database
docker exec appwrite-mariadb mysqldump -u appwrite -p appwrite > backup.sql

# Restore
docker exec -i appwrite-mariadb mysql -u appwrite -p appwrite < backup.sql
```

## 📊 Performance Tips

1. **Optimize Check Interval**
   - 30s for active trading
   - 60s+ for longer-term strategies

2. **Limit Watchlist Size**
   - 5-10 symbols max for 30s intervals
   - More symbols = longer cycles

3. **Resource Allocation**
   - 512MB RAM minimum
   - 1GB recommended for production

## 📞 Support

- GitHub Issues: [Report bugs](https://github.com/mayankjanmejay/babel_binance/issues)
- Documentation: See `PROJECT_ANALYSIS_AND_ROADMAP.md`

## ⚖️ Legal Disclaimer

This software is provided "as is" without warranty. Use at your own risk. Cryptocurrency trading involves substantial risk of loss. The authors are not responsible for any financial losses incurred.

Always:
- Test in simulation mode first
- Never invest more than you can afford to lose
- Understand the risks of automated trading
- Comply with local regulations

## 📄 License

MIT License - See LICENSE file for details
