# ⚡ Quick Start Guide - 24/7 Trading Bot

Get your trading bot running in 5 minutes!

## 🚀 Method 1: Docker Compose (Easiest - Recommended)

### Step 1: Prerequisites
```bash
# Install Docker and Docker Compose if not already installed
# Visit: https://docs.docker.com/get-docker/

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Configure Environment
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your credentials
nano .env  # or use your preferred editor
```

**Required settings in `.env`:**
```bash
BINANCE_API_KEY=your_api_key_here
BINANCE_API_SECRET=your_secret_here
APPWRITE_ENDPOINT=http://appwrite/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
BOT_SIMULATION_MODE=true  # Keep true for testing!
```

### Step 3: Start Services
```bash
# Start Appwrite and trading bot
docker-compose up -d

# View logs
docker-compose logs -f trading-bot
```

### Step 4: Setup Database
```bash
# Wait 30 seconds for Appwrite to fully start
sleep 30

# Run setup script
chmod +x scripts/setup_appwrite.sh
./scripts/setup_appwrite.sh
```

### Step 5: Add Symbols to Watch
```bash
# Add symbols via script
chmod +x scripts/add_to_watchlist.sh
export APPWRITE_PROJECT_ID=your_project_id
export APPWRITE_API_KEY=your_api_key

./scripts/add_to_watchlist.sh BTCUSDT
./scripts/add_to_watchlist.sh ETHUSDT
./scripts/add_to_watchlist.sh BNBUSDT

# Verify
docker-compose logs trading-bot | grep "Watching"
```

### Step 6: Monitor
```bash
# Check health
curl http://localhost:8080/health

# View live logs
docker-compose logs -f trading-bot

# Check statistics
docker-compose logs trading-bot | grep "Health check"
```

**Done! Your bot is now running 24/7** ✅

---

## 🖥️ Method 2: Direct Run (Development)

### Step 1: Install Dart
```bash
# Linux
sudo apt-get update
sudo apt-get install dart

# macOS
brew tap dart-lang/dart
brew install dart

# Verify
dart --version
```

### Step 2: Setup Appwrite Separately
```bash
# If you don't have Appwrite running, start it:
docker run -d \
  --name appwrite \
  -p 80:80 \
  -p 443:443 \
  appwrite/appwrite:1.5
```

### Step 3: Configure and Run
```bash
# Install dependencies
dart pub get

# Copy and configure .env
cp .env.example .env
nano .env

# Run the bot
dart run bin/server.dart
```

---

## 🐧 Method 3: Systemd Service (Production Linux)

### Step 1: Compile Bot
```bash
# Install dependencies
dart pub get

# Compile to native executable
dart compile exe bin/server.dart -o trading_bot

# Test it works
./trading_bot
# Press Ctrl+C to stop
```

### Step 2: Install as Service
```bash
# Create directories
sudo mkdir -p /opt/trading-bot
sudo mkdir -p /var/log/trading-bot

# Copy files
sudo cp trading_bot /opt/trading-bot/
sudo cp .env /opt/trading-bot/

# Create user
sudo useradd -r -s /bin/false bot
sudo chown -R bot:bot /opt/trading-bot /var/log/trading-bot

# Install service
sudo cp trading-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Step 3: Start Service
```bash
# Enable on boot
sudo systemctl enable trading-bot

# Start now
sudo systemctl start trading-bot

# Check status
sudo systemctl status trading-bot

# View logs
sudo journalctl -u trading-bot -f
```

---

## 📊 Verification Checklist

After starting, verify everything works:

- [ ] Bot starts without errors
- [ ] Connects to Appwrite successfully
- [ ] Connects to Binance API successfully
- [ ] Loads watchlist (or shows empty warning)
- [ ] Completes trading cycles every 30 seconds
- [ ] Health check endpoint responds: `curl localhost:8080/health`
- [ ] Logs show price updates for watched symbols

Example healthy logs:
```
[12:30:00] INFO: 🤖 Starting Trading Bot
[12:30:00] INFO: ✅ Appwrite service initialized
[12:30:01] INFO: 📋 Watching 3 symbols: BTCUSDT, ETHUSDT, BNBUSDT
[12:30:01] INFO: ✅ Trading bot started successfully
[12:30:05] FINE: 🔄 Starting trading cycle #1
[12:30:06] FINE: BTCUSDT: $95234.56
[12:30:06] FINE: ETHUSDT: $3456.78
[12:30:06] FINE: BNBUSDT: $645.32
[12:30:07] FINE: ✅ Cycle #1 completed in 2341ms
```

---

## 🎯 Adding Symbols to Watch

### Method 1: Appwrite Console UI
1. Open http://localhost (or your Appwrite URL)
2. Navigate to Databases → crypto_trading → watchlist
3. Click "Add Document"
4. Fill in:
   - user_id: `default_user`
   - symbol: `BTCUSDT`
   - active: `true`
   - created_at: Current time

### Method 2: Script (Faster)
```bash
# Set your Appwrite credentials
export APPWRITE_PROJECT_ID=your_project
export APPWRITE_API_KEY=your_key

# Add symbols
./scripts/add_to_watchlist.sh BTCUSDT
./scripts/add_to_watchlist.sh ETHUSDT
./scripts/add_to_watchlist.sh SOLUSDT
./scripts/add_to_watchlist.sh ADAUSDT
```

### Method 3: Direct API Call
```bash
curl -X POST "http://localhost/v1/databases/crypto_trading/collections/watchlist/documents" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: YOUR_PROJECT_ID" \
  -H "X-Appwrite-Key: YOUR_API_KEY" \
  -d '{
    "documentId": "unique()",
    "data": {
      "user_id": "default_user",
      "symbol": "BTCUSDT",
      "active": true,
      "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'"
    }
  }'
```

---

## ⚙️ Common Configurations

### High-Frequency Trading (Active Trader)
```bash
# .env
BOT_CHECK_INTERVAL_SECONDS=10  # Check every 10 seconds
```

### Conservative Trading (Long-term)
```bash
# .env
BOT_CHECK_INTERVAL_SECONDS=300  # Check every 5 minutes
```

### Enable Only Specific Algorithms

Edit `bin/server.dart`:
```dart
final algorithms = [
  SMACrossover(...),     // ✅ Enabled
  // RSIStrategy(...),   // ❌ Disabled (commented)
  // GridTrading(...),   // ❌ Disabled
];
```

---

## 🔧 Troubleshooting

### Bot Not Finding Symbols
```bash
# Check watchlist
docker-compose exec appwrite appwrite databases listDocuments \
  --databaseId crypto_trading \
  --collectionId watchlist
```

### Connection Errors
```bash
# Restart everything
docker-compose restart

# Check Appwrite is running
docker ps | grep appwrite

# Test Binance API
curl https://api.binance.com/api/v3/time
```

### No Trades Executing
1. Ensure `BOT_ENABLE_TRADING=true` in .env
2. Check if algorithms are active
3. Market conditions may not meet trading criteria
4. In simulation mode, all trades are fake (this is normal!)

---

## 🎓 Next Steps

1. **Monitor for 24-48 hours** in simulation mode
2. **Review trade logs** to understand algorithm behavior
3. **Adjust parameters** in `bin/server.dart` if needed
4. **Add more symbols** to diversify
5. **When ready for live trading:**
   ```bash
   # .env
   BOT_SIMULATION_MODE=false  # ⚠️ CAUTION: Real money!
   BOT_ENABLE_TRADING=true
   ```

---

## 📞 Getting Help

- Check logs: `docker-compose logs trading-bot`
- Health status: `curl localhost:8080/health`
- Full docs: See `README.md`
- Issues: https://github.com/mayankjanmejay/babel_binance/issues

**Happy Trading! 🚀📈**
