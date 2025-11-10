# ⚡ Quick Start - Complete Trading Platform

**Get your trading platform running in 5 minutes!**

---

## 🎯 What You're Getting

A complete cryptocurrency trading platform with:
- ✅ 24/7 automated trading bot
- ✅ Web dashboard for monitoring
- ✅ REST API for integration
- ✅ Database backend (Appwrite)
- ✅ Everything in Docker containers

**All in ONE command!**

---

## 🚀 5-Minute Setup

### Step 1: Prerequisites (2 minutes)

Install Docker:
```bash
# Linux (Ubuntu)
curl -fsSL https://get.docker.com | sh

# macOS/Windows
# Download Docker Desktop from docker.com
```

Verify:
```bash
docker --version  # Should show 20.10+
docker-compose --version  # Should show 2.0+
```

### Step 2: Get Binance API Keys (2 minutes)

1. Go to https://www.binance.com/en/my/settings/api-management
2. Click "Create API"
3. Complete 2FA verification
4. Enable "Enable Reading" + "Enable Spot & Margin Trading"
5. Copy API Key and Secret (save somewhere safe)

### Step 3: Configure (30 seconds)

```bash
# In your project directory
cp .env.example bot_service/.env
nano bot_service/.env
```

Update these lines:
```bash
BINANCE_API_KEY=paste_your_api_key_here
BINANCE_API_SECRET=paste_your_secret_here
```

Save and exit (Ctrl+X, Y, Enter)

### Step 4: Start Everything! (30 seconds)

```bash
docker-compose up -d
```

Wait 30 seconds for services to start.

### Step 5: Setup Appwrite (1 minute)

1. Open http://localhost in browser
2. Create admin account (email + password)
3. Click "Create Project" → Name it "Crypto Trading"
4. Copy the Project ID shown
5. Go to "API Keys" → "Add API Key"
6. Name: "Bot" → Select all database scopes → Create
7. Copy the API Key

Update `.env`:
```bash
nano bot_service/.env

# Update these lines:
APPWRITE_PROJECT_ID=paste_project_id_here
APPWRITE_API_KEY=paste_api_key_here
```

### Step 6: Create Database Collections (2 minutes)

In Appwrite console (http://localhost):

1. Click "Databases" → "Create Database"
   - ID: `crypto_trading`
   - Name: "Crypto Trading"

2. Create 4 collections:

**Collection 1: watchlist**
- Click "Add Collection"
- ID: `watchlist`, Name: "Watchlist"
- Permissions: Enable all (read, create, update, delete)
- Add attributes:
  - `user_id` - String - Size: 255 - Required
  - `symbol` - String - Size: 20 - Required
  - `target_buy` - Float - Optional
  - `target_sell` - Float - Optional
  - `active` - Boolean - Required - Default: true
  - `created_at` - DateTime - Required

**Collection 2: trades**
- ID: `trades`, Name: "Trades"
- Permissions: Enable read, create
- Add attributes:
  - `user_id` - String - 255 - Required
  - `symbol` - String - 20 - Required
  - `side` - String - 10 - Required
  - `quantity` - Float - Required
  - `price` - Float - Required
  - `total_value` - Float - Required
  - `timestamp` - DateTime - Required
  - `algorithm_name` - String - 100 - Required
  - `order_id` - String - 100 - Optional
  - `status` - String - 20 - Required

**Collection 3: portfolios**
- ID: `portfolios`, Name: "Portfolios"
- Permissions: Enable read, create, update
- Add attributes:
  - `user_id` - String - 255 - Required
  - `asset` - String - 20 - Required
  - `quantity` - Float - Required
  - `avg_buy_price` - Float - Required
  - `updated_at` - DateTime - Required

**Collection 4: algorithms**
- ID: `algorithms`, Name: "Algorithms"
- Permissions: Enable read, create, update
- Add attributes:
  - `user_id` - String - 255 - Required
  - `name` - String - 100 - Required
  - `type` - String - 50 - Required
  - `params` - String - 1000 - Required
  - `active` - Boolean - Required - Default: true

### Step 7: Restart Services (10 seconds)

```bash
docker-compose restart
```

### Step 8: Access Dashboard! (5 seconds)

Open http://localhost:8888

**You should see:**
- Statistics dashboard
- Empty watchlist
- Live prices section
- Empty trade history

---

## ✅ Verification Checklist

Check that everything is working:

```bash
# 1. All services running
docker-compose ps
# Should show 6 services as "Up"

# 2. API server healthy
curl http://localhost:3000/health
# Should return: {"status":"healthy",...}

# 3. Bot healthy
docker-compose logs trading-bot | tail -20
# Should see: "✅ Trading bot started successfully"

# 4. Web UI accessible
curl http://localhost:8888
# Should return HTML content
```

---

## 🎯 Add Your First Symbol

### Via Web Dashboard (Easiest)

1. Go to http://localhost:8888
2. Click "+ Add Symbol" button
3. Enter: `BTCUSDT`
4. Leave targets blank (or set if you want)
5. Click "Add Symbol"
6. Wait 30 seconds
7. Refresh page - you should see Bitcoin price!

### Via Command Line

```bash
# Add BTC, ETH, BNB
docker-compose exec api-server sh -c '
curl -X POST http://localhost:3000/api/watchlist \
  -H "Content-Type: application/json" \
  -d "{\"symbol\":\"BTCUSDT\"}"
'
```

---

## 📊 Monitor Your Bot

### View Live Logs

```bash
# All services
docker-compose logs -f

# Just the bot
docker-compose logs -f trading-bot

# Just the API
docker-compose logs -f api-server
```

### Check Statistics

```bash
# Via API
curl http://localhost:3000/api/trades/stats | jq

# Or open web dashboard
open http://localhost:8888
```

### View Recent Trades

Open http://localhost:8888 and scroll to "Recent Trades" section.

---

## 🛑 Stop/Start

```bash
# Stop all services
docker-compose down

# Start again
docker-compose up -d

# Restart specific service
docker-compose restart trading-bot
```

---

## ⚙️ Important Settings

### Simulation vs Live Trading

**By default, you're in SIMULATION mode** (safe!).

To check:
```bash
grep BOT_SIMULATION_MODE bot_service/.env
# Should show: BOT_SIMULATION_MODE=true
```

**To enable LIVE trading** (⚠️ real money!):
```bash
nano bot_service/.env
# Change: BOT_SIMULATION_MODE=false
docker-compose restart trading-bot
```

### Trading Frequency

How often bot checks prices (default: 30 seconds):
```bash
# In .env:
BOT_CHECK_INTERVAL_SECONDS=30

# For more frequent (10 seconds):
BOT_CHECK_INTERVAL_SECONDS=10

# For less frequent (5 minutes):
BOT_CHECK_INTERVAL_SECONDS=300
```

### Algorithm Parameters

Edit `bot_service/bin/server.dart`:

```dart
final algorithms = [
  SMACrossover(
    shortPeriod: 20,    // Lower = more signals
    longPeriod: 50,     // Higher = fewer signals
    quantity: 0.001,    // Amount per trade
  ),
  // ... more algorithms
];
```

After editing, rebuild:
```bash
docker-compose build trading-bot
docker-compose restart trading-bot
```

---

## 📱 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **Web Dashboard** | http://localhost:8888 | Main UI |
| **Appwrite Console** | http://localhost | Database admin |
| **API Server** | http://localhost:3000 | REST API |
| **Bot Health** | http://localhost:8080/health | Internal only |

---

## 🔥 Pro Tips

1. **Always test in simulation first**
   - Run for at least 1 week
   - Verify signals make sense
   - Check no errors in logs

2. **Start with small amounts**
   - When going live, use tiny quantities
   - Monitor first 24 hours closely

3. **Use multiple symbols**
   - Add 3-5 pairs for diversification
   - More data for algorithms to work with

4. **Monitor daily**
   - Check web dashboard daily
   - Review trade history
   - Adjust parameters if needed

5. **Keep backups**
   ```bash
   # Backup database weekly
   docker exec crypto-mariadb mysqldump -u appwrite -p appwrite > backup.sql
   ```

---

## 🐛 Quick Troubleshooting

### "Cannot connect to API"
```bash
docker-compose restart api-server
docker-compose logs api-server
```

### "Watchlist is empty"
- Add symbols via web dashboard
- Check Appwrite console → databases → watchlist

### "No trades executing"
- Normal if in simulation mode
- Check bot logs: `docker-compose logs trading-bot`
- Market may not meet algorithm conditions

### "Out of memory"
```bash
docker stats
# If high, reduce check interval or limit containers
```

---

## 📚 Full Documentation

- **Complete Guide**: `ALL_IN_ONE_SETUP.md` (everything in detail)
- **Bot Service**: `bot_service/README.md` (bot-specific)
- **Project Roadmap**: `PROJECT_ANALYSIS_AND_ROADMAP.md` (future plans)
- **Bot Summary**: `BOT_SERVICE_SUMMARY.md` (quick reference)

---

## 🎉 You're Done!

Your complete trading platform is now running!

**What to do next:**
1. ✅ Add 3-5 symbols to watchlist
2. ✅ Monitor for 24-48 hours
3. ✅ Review trades in dashboard
4. ✅ Adjust algorithm parameters
5. ✅ When confident, consider live trading (your risk!)

**Happy Trading!** 🚀📈💰

---

## 🆘 Need Help?

- Check `ALL_IN_ONE_SETUP.md` for detailed FAQ
- View logs: `docker-compose logs -f trading-bot`
- GitHub Issues: Report problems
- Review trades: http://localhost:8888

**Remember:** Start in simulation mode, test thoroughly, never invest more than you can afford to lose!
