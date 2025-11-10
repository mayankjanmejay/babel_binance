# 🚀 Complete All-in-One Crypto Trading Platform

**One Docker command. Complete trading platform.**

This setup includes:
- ✅ **Appwrite Backend** (Database, Auth, Storage)
- ✅ **Trading Bot** (24/7 automated trading with 3 algorithms)
- ✅ **REST API Server** (Communication layer)
- ✅ **Web Dashboard** (Beautiful UI for monitoring & control)

---

## 📋 Table of Contents

- [Quick Start (5 Minutes)](#quick-start-5-minutes)
- [What's Included](#whats-included)
- [System Requirements](#system-requirements)
- [Installation Guide](#installation-guide)
- [Configuration](#configuration)
- [First-Time Setup](#first-time-setup)
- [Using the Web Dashboard](#using-the-web-dashboard)
- [Managing the System](#managing-the-system)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Architecture Overview](#architecture-overview)

---

## ⚡ Quick Start (5 Minutes)

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd babel_binance

# 2. Copy environment file
cp .env.example bot_service/.env

# 3. Start everything
docker-compose up -d

# 4. Open web dashboard
open http://localhost:8888

# 5. Setup Appwrite (first time only)
# Go to http://localhost and follow setup wizard
# Then update bot_service/.env with your Appwrite credentials
# Finally: docker-compose restart
```

**That's it!** Your complete trading platform is now running.

---

## 🎯 What's Included

### 1. **Appwrite Backend** (Port 80/443)
- User authentication
- Database (MariaDB)
- Storage for logs and backups
- Real-time subscriptions
- RESTful API

### 2. **Trading Bot Service** (Background)
- 24/7 automated trading
- 3 built-in algorithms:
  - SMA Crossover (Moving Averages)
  - RSI Strategy (Oversold/Overbought)
  - Grid Trading (Multiple price levels)
- Multi-coin monitoring
- Risk management
- Trade logging

### 3. **REST API Server** (Port 3000)
- Market data endpoints
- Watchlist management
- Trade history
- Statistics & analytics
- Bot control (future)

### 4. **Web Dashboard** (Port 8888)
- Live price monitoring
- Watchlist management
- Recent trades view
- Statistics dashboard
- Add/remove symbols
- Real-time updates

### 5. **Supporting Services**
- MariaDB (Database)
- Redis (Caching)
- Nginx (Web server)

---

## 💻 System Requirements

### Minimum
- CPU: 2 cores
- RAM: 4 GB
- Disk: 10 GB free
- OS: Linux, macOS, or Windows (with WSL2)

### Recommended
- CPU: 4 cores
- RAM: 8 GB
- Disk: 20 GB SSD
- OS: Linux (Ubuntu 20.04+)

### Software
- Docker Engine 20.10+
- Docker Compose 2.0+
- Internet connection (for Binance API)

---

## 📦 Installation Guide

### Step 1: Install Docker

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

**macOS:**
```bash
# Download Docker Desktop from:
# https://www.docker.com/products/docker-desktop
```

**Windows:**
```bash
# Download Docker Desktop from:
# https://www.docker.com/products/docker-desktop
# Enable WSL2 backend
```

Verify installation:
```bash
docker --version
docker-compose --version
```

### Step 2: Clone Repository

```bash
git clone <your-repo-url>
cd babel_binance
```

### Step 3: Configure Environment

```bash
# Copy example configuration
cp .env.example bot_service/.env

# Edit with your editor of choice
nano bot_service/.env
# or
code bot_service/.env
```

**Required values in `.env`:**
```bash
# Get from https://www.binance.com/en/my/settings/api-management
BINANCE_API_KEY=your_actual_api_key
BINANCE_API_SECRET=your_actual_secret

# These will be filled after Appwrite setup (Step 4)
APPWRITE_PROJECT_ID=get_after_setup
APPWRITE_API_KEY=get_after_setup
```

### Step 4: Start the Platform

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

**Expected output:**
```
NAME                     STATUS         PORTS
crypto-appwrite          Up (healthy)   80/tcp, 443/tcp
crypto-mariadb           Up (healthy)   3306/tcp
crypto-redis             Up (healthy)   6379/tcp
crypto-api-server        Up (healthy)   3000/tcp
crypto-trading-bot       Up (healthy)   8080/tcp
crypto-web-ui            Up             8888/tcp
```

---

## ⚙️ Configuration

### Binance API Setup

1. Go to https://www.binance.com/en/my/settings/api-management
2. Create new API key
3. **Important settings:**
   - Enable "Enable Spot & Margin Trading" (for live trading)
   - Enable "Enable Reading" (required)
   - Add IP restriction (recommended)
   - Do NOT enable withdrawals
4. Copy API Key and Secret to `bot_service/.env`

### Appwrite Setup (First Time)

1. Open http://localhost in browser
2. Complete Appwrite setup wizard:
   - Create admin account
   - Set admin password
3. Create new project:
   - Click "Create Project"
   - Name: "Crypto Trading"
   - Copy Project ID
4. Generate API Key:
   - Go to Project Settings → API Keys
   - Click "Add API Key"
   - Name: "Trading Bot"
   - Scopes: Select all database scopes
   - Copy API Key
5. Create database:
   - Go to Databases → Create Database
   - Database ID: `crypto_trading`
   - Name: "Crypto Trading"
6. Create collections (4 collections needed):

#### Collection 1: `watchlist`
```json
{
  "collectionId": "watchlist",
  "name": "Watchlist",
  "permissions": ["read", "create", "update", "delete"],
  "attributes": [
    {"key": "user_id", "type": "string", "size": 255, "required": true},
    {"key": "symbol", "type": "string", "size": 20, "required": true},
    {"key": "target_buy", "type": "float", "required": false},
    {"key": "target_sell", "type": "float", "required": false},
    {"key": "active", "type": "boolean", "required": true, "default": true},
    {"key": "created_at", "type": "datetime", "required": true}
  ]
}
```

#### Collection 2: `trades`
```json
{
  "collectionId": "trades",
  "name": "Trades",
  "permissions": ["read", "create"],
  "attributes": [
    {"key": "user_id", "type": "string", "size": 255, "required": true},
    {"key": "symbol", "type": "string", "size": 20, "required": true},
    {"key": "side", "type": "string", "size": 10, "required": true},
    {"key": "quantity", "type": "float", "required": true},
    {"key": "price", "type": "float", "required": true},
    {"key": "total_value", "type": "float", "required": true},
    {"key": "timestamp", "type": "datetime", "required": true},
    {"key": "algorithm_name", "type": "string", "size": 100, "required": true},
    {"key": "order_id", "type": "string", "size": 100, "required": false},
    {"key": "status", "type": "string", "size": 20, "required": true}
  ]
}
```

#### Collection 3: `portfolios`
```json
{
  "collectionId": "portfolios",
  "name": "Portfolios",
  "permissions": ["read", "create", "update"],
  "attributes": [
    {"key": "user_id", "type": "string", "size": 255, "required": true},
    {"key": "asset", "type": "string", "size": 20, "required": true},
    {"key": "quantity", "type": "float", "required": true},
    {"key": "avg_buy_price", "type": "float", "required": true},
    {"key": "updated_at", "type": "datetime", "required": true}
  ]
}
```

#### Collection 4: `algorithms`
```json
{
  "collectionId": "algorithms",
  "name": "Algorithms",
  "permissions": ["read", "create", "update"],
  "attributes": [
    {"key": "user_id", "type": "string", "size": 255, "required": true},
    {"key": "name", "type": "string", "size": 100, "required": true},
    {"key": "type", "type": "string", "size": 50, "required": true},
    {"key": "params", "type": "string", "size": 1000, "required": true},
    {"key": "active", "type": "boolean", "required": true, "default": true}
  ]
}
```

7. Update `bot_service/.env`:
```bash
APPWRITE_PROJECT_ID=<your_project_id>
APPWRITE_API_KEY=<your_api_key>
```

8. Restart services:
```bash
docker-compose restart
```

---

## 🎨 Using the Web Dashboard

### Access the Dashboard

Open http://localhost:8888 in your browser

### Dashboard Features

#### 1. **Statistics Cards** (Top Row)
- Total Trades: All executed trades
- Buy Orders: Number of buy trades
- Sell Orders: Number of sell trades
- Total Volume: Total USD value traded

#### 2. **Watchlist Panel** (Left)
- View all monitored symbols
- Add new symbols with "+" button
- Set target buy/sell prices (optional)
- Remove symbols with trash icon

**Adding a Symbol:**
1. Click "+ Add Symbol" button
2. Enter symbol (e.g., BTCUSDT, ETHUSDT)
3. Optionally set target prices
4. Click "Add Symbol"

#### 3. **Live Prices Panel** (Right)
- Real-time price updates
- 24-hour price change percentage
- Trading volume
- High/Low prices
- Auto-refreshes every 30 seconds

#### 4. **Recent Trades Panel** (Bottom)
- Last 20 trades
- Timestamp, symbol, side (buy/sell)
- Quantity, price, total value
- Algorithm that triggered trade
- Order status

### Dashboard Controls

- **Refresh Prices**: Manually update live prices
- **Add Symbol**: Add cryptocurrency to watchlist
- **Remove Symbol**: Delete from watchlist
- **Auto-refresh**: Updates every 30 seconds automatically

---

## 🔧 Managing the System

### Start/Stop Services

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart trading-bot
docker-compose restart api-server
docker-compose restart web-ui

# View logs
docker-compose logs -f trading-bot
docker-compose logs -f api-server

# Check status
docker-compose ps
```

### Update the System

```bash
# Pull latest code
git pull

# Rebuild containers
docker-compose build

# Restart with new code
docker-compose up -d
```

### Backup Data

```bash
# Backup Appwrite database
docker exec crypto-mariadb mysqldump -u appwrite -p appwrite > backup-$(date +%Y%m%d).sql

# Backup volumes
docker run --rm \
  -v babel_binance_appwrite-uploads:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/appwrite-backup.tar.gz /data
```

### Restore Data

```bash
# Restore database
docker exec -i crypto-mariadb mysql -u appwrite -p appwrite < backup.sql

# Restore volumes
docker run --rm \
  -v babel_binance_appwrite-uploads:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/appwrite-backup.tar.gz -C /
```

### Monitor Resources

```bash
# View resource usage
docker stats

# View disk usage
docker system df

# Clean up unused images/volumes
docker system prune -a
```

---

## 🐛 Troubleshooting

### Services Not Starting

**Problem:** Docker containers fail to start

**Solutions:**
```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs trading-bot

# Verify ports not in use
sudo lsof -i :80    # Appwrite
sudo lsof -i :3000  # API Server
sudo lsof -i :8888  # Web UI

# Restart Docker
sudo systemctl restart docker
```

### Cannot Connect to Appwrite

**Problem:** Bot or API can't reach Appwrite

**Solutions:**
```bash
# Verify Appwrite is running
docker-compose ps appwrite

# Check Appwrite logs
docker-compose logs appwrite

# Verify network
docker network inspect babel_binance_crypto-network

# Check .env endpoint
# Should be: APPWRITE_ENDPOINT=http://appwrite/v1
```

### Web Dashboard Shows "Offline"

**Problem:** Dashboard can't connect to API

**Solutions:**
```bash
# Check API server status
curl http://localhost:3000/health

# Check API server logs
docker-compose logs api-server

# Verify CORS settings in web_ui/app.js
# API_BASE_URL should be 'http://localhost:3000'
```

### No Trades Executing

**Problem:** Bot runs but doesn't execute trades

**Checklist:**
1. Is simulation mode enabled? (Expected behavior)
   ```bash
   # In .env:
   BOT_SIMULATION_MODE=true  # Trades are fake
   ```

2. Is watchlist empty?
   ```bash
   # Add symbols via web dashboard
   # Or check Appwrite console
   ```

3. Are algorithms active?
   ```bash
   # Check bot logs
   docker-compose logs trading-bot | grep "Algorithms"
   ```

4. Do market conditions meet criteria?
   ```bash
   # Algorithms may not trigger if:
   # - Price not crossed SMA levels
   # - RSI not oversold/overbought
   # - Grid levels not hit
   ```

### Out of Memory

**Problem:** Docker containers using too much RAM

**Solutions:**
```bash
# Check memory usage
docker stats

# Limit bot memory in docker-compose.yml
services:
  trading-bot:
    mem_limit: 512m

# Restart containers
docker-compose restart
```

### Database Connection Errors

**Problem:** "Failed to connect to database"

**Solutions:**
```bash
# Verify MariaDB is running
docker-compose ps mariadb

# Check MariaDB logs
docker-compose logs mariadb

# Reset database (⚠️ deletes data)
docker-compose down -v
docker-compose up -d
```

---

## ❓ FAQ

### General Questions

**Q: Is this safe for real trading?**
A: Start in simulation mode (`BOT_SIMULATION_MODE=true`) to test without risk. When ready for live trading, start with tiny amounts and monitor closely.

**Q: How much does it cost to run?**
A: Infrastructure costs ~$20-50/month for a VPS. Binance API is free. Trading fees are 0.1% per trade.

**Q: Can I run this on my local computer?**
A: Yes! Works great on Docker Desktop (Windows/Mac) or native Docker (Linux).

**Q: Do I need programming knowledge?**
A: No. Basic Docker commands and configuration editing is enough. All code is provided.

### Trading Questions

**Q: Which cryptocurrencies can I trade?**
A: Any symbol available on Binance Spot market (BTC, ETH, BNB, SOL, ADA, DOGE, etc.)

**Q: How do algorithms work?**
A:
- **SMA Crossover**: Buys when 20-day moving average crosses above 50-day
- **RSI Strategy**: Buys when RSI < 30 (oversold), sells when > 70 (overbought)
- **Grid Trading**: Places buy orders below price, sell orders above, profits from volatility

**Q: Can I customize algorithms?**
A: Yes! Edit `bot_service/bin/server.dart` to adjust parameters like periods, thresholds, quantities.

**Q: How often does the bot check prices?**
A: Every 30 seconds by default. Change `BOT_CHECK_INTERVAL_SECONDS` in `.env`.

**Q: Can I add my own algorithms?**
A: Yes! Create a new class extending `TradingAlgorithm` in `bot_service/lib/algorithms/`. See existing ones as examples.

### Technical Questions

**Q: What databases are used?**
A: MariaDB (via Appwrite) for persistent data, Redis for caching.

**Q: Where are logs stored?**
A: View with `docker-compose logs trading-bot`. Persistent logs in `bot_service/logs/` directory.

**Q: Can I run multiple bots?**
A: Yes! Duplicate `bot_service` directory, update `.env`, add to `docker-compose.yml` with different name.

**Q: How do I update to new versions?**
A:
```bash
git pull
docker-compose build
docker-compose up -d
```

**Q: What happens if power goes out?**
A: Docker containers auto-restart. All trades logged to database. Position tracking resumes on restart.

**Q: Can I trade on testnet?**
A: Binance doesn't have public testnet. Use `BOT_SIMULATION_MODE=true` for safe testing.

### Security Questions

**Q: How are API keys secured?**
A: Stored in `.env` file (not committed to git). Run containers as non-root user. Network isolated.

**Q: Should I enable IP whitelist on Binance?**
A: Highly recommended! Get your server's IP and add to Binance API settings.

**Q: What permissions should Binance API have?**
A: Enable: Reading, Spot Trading. Disable: Withdrawals, Futures (unless needed).

**Q: Is the web dashboard secure?**
A: Basic setup has no authentication. For production, add nginx auth or VPN. Never expose port 8888 to internet without protection.

### Troubleshooting Questions

**Q: Bot says "Appwrite connection failed"**
A: Check Appwrite is running (`docker-compose ps`) and `.env` has correct `APPWRITE_PROJECT_ID` and `APPWRITE_API_KEY`.

**Q: Web UI shows no data**
A: Ensure API server is running (`docker-compose ps api-server`). Check browser console for errors (F12).

**Q: Trades not saving to database**
A: Verify Appwrite collections exist. Check bot logs: `docker-compose logs trading-bot | grep "Saved trade"`.

**Q: High CPU usage**
A: Normal during price checks. If constant 100%, increase `BOT_CHECK_INTERVAL_SECONDS` or reduce watchlist size.

---

## 🏗️ Architecture Overview

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                │
└──────────────────┬──────────────────────────────────────────┘
                   │
         ┌─────────▼──────────┐
         │   WEB DASHBOARD    │
         │  (Port 8888)       │
         │  - Live Prices     │
         │  - Watchlist       │
         │  - Trade History   │
         └─────────┬──────────┘
                   │ HTTP
         ┌─────────▼──────────┐
         │   API SERVER       │
         │  (Port 3000)       │
         │  - REST API        │
         │  - Market Data     │
         │  - Database ORM    │
         └─────────┬──────────┘
                   │
    ┌──────────────┼──────────────┐
    │              │              │
┌───▼───┐    ┌────▼─────┐   ┌───▼────┐
│TRADING│    │ APPWRITE │   │BINANCE │
│  BOT  │◄───┤ BACKEND  │   │  API   │
│       │    │          │   │        │
│- SMA  │    │- MariaDB │   │- Spot  │
│- RSI  │    │- Redis   │   │- Margin│
│- Grid │    │- Storage │   │- Wallet│
└───────┘    └──────────┘   └────────┘
```

### Component Communication

1. **User** → **Web Dashboard**: Browser access on port 8888
2. **Web Dashboard** → **API Server**: AJAX requests for data
3. **API Server** → **Appwrite**: Database queries, auth
4. **API Server** → **Binance API**: Market data via babel_binance
5. **Trading Bot** → **Appwrite**: Save trades, load watchlist
6. **Trading Bot** → **Binance API**: Execute trades via babel_binance

### Data Flow

#### Price Monitoring
```
Bot → Check interval (30s) → Fetch prices from Binance →
Run algorithms → Generate signals → Execute trades →
Save to Appwrite → Display in dashboard
```

#### User Adding Symbol
```
User → Click "Add Symbol" → Web Dashboard → POST to API →
API saves to Appwrite → Bot picks up on next refresh →
Starts monitoring → Prices shown in dashboard
```

### Network Topology

All services on `crypto-network` bridge:
- Containers communicate by service name (e.g., `http://appwrite/v1`)
- External access via published ports (80, 3000, 8888)
- Isolated from host network for security

### Storage

**Volumes:**
- `mariadb-data`: Database files (persistent)
- `redis-data`: Cache data
- `appwrite-*`: Appwrite storage (uploads, config, etc.)
- `bot_service/logs`: Bot logs (mounted from host)

**Persistence:**
- All trades: MariaDB via Appwrite
- Watchlist: MariaDB via Appwrite
- Logs: File system (host-mounted)
- Configuration: `.env` file (host)

---

## 📞 Support & Resources

### Documentation
- **This Guide**: Complete all-in-one setup
- **Bot Service README**: `bot_service/README.md`
- **API Documentation**: Check API endpoints in `api_server/bin/server.dart`
- **Project Roadmap**: `PROJECT_ANALYSIS_AND_ROADMAP.md`

### External Resources
- **Binance API Docs**: https://binance-docs.github.io/apidocs/
- **Appwrite Docs**: https://appwrite.io/docs
- **Docker Docs**: https://docs.docker.com/
- **babel_binance Library**: Main `README.md`

### Community
- **Issues**: GitHub Issues (report bugs)
- **Discussions**: GitHub Discussions (ask questions)
- **Updates**: Watch repository for new releases

---

## 🎉 You're Ready!

Your complete crypto trading platform is now set up and running!

**Quick reference:**
- 🌐 Web Dashboard: http://localhost:8888
- 🔧 Appwrite Console: http://localhost
- 📊 API Health: http://localhost:3000/health
- 🤖 Bot Health: http://localhost:8080/health (internal)

**Next steps:**
1. Add symbols to watchlist via web dashboard
2. Monitor for 24-48 hours in simulation mode
3. Review trades and adjust algorithm parameters
4. When confident, switch to live trading (at your own risk!)

**Happy Trading!** 🚀📈💰
