# Implementation Status - Real-Time Features

This document tracks the implementation of three major features requested:
1. Performance Charts
2. Price Alerts
3. Multi-Algorithm Strategy

---

## ✅ COMPLETED: Performance Charts (100%)

### Backend (Complete)
- ✅ `/api/performance/summary` - Overall P&L, win rate, averages
- ✅ `/api/performance/chart` - Time-series cumulative P&L data
- ✅ `/api/performance/algorithms` - Per-algorithm comparison

### Frontend (Complete)
- ✅ `performance.js` - Chart.js integration with 3 charts:
  - P&L over time (line + bar combo)
  - Win/Loss distribution (doughnut chart)
  - Algorithm performance comparison (bar chart)
- ✅ `performance.css` - Responsive design with dark mode
- ✅ 6 summary metric cards (Total P&L, Win Rate, Avg Profit/Loss, Wins/Losses)
- ⚠️ **Currently polls every 30s** - Needs WebSocket integration

**Status**: Feature complete, but needs WebSocket upgrade for real-time updates.

---

## 🟡 IN PROGRESS: Real-Time WebSocket Streams (60%)

### Backend (Complete)
- ✅ `WebSocketService` class in `api_server/lib/websocket_service.dart`
  - Connects to Binance WebSocket API for live price feeds
  - Broadcasts price updates to all connected clients
  - Handles subscribe/unsubscribe to symbols
  - Heartbeat to keep connections alive
- ✅ WebSocket endpoint: `WS /ws`
- ✅ Stats endpoint: `GET /api/ws/stats`
- ✅ Dependencies added: `shelf_web_socket`, `web_socket_channel`

### Frontend (TODO)
- ❌ Create `websocket-client.js` to connect to `/ws`
- ❌ Replace polling in `app.js` with WebSocket listeners
- ❌ Replace polling in `performance.js` with WebSocket updates
- ❌ Real-time chart updates without page refresh
- ❌ Visual indicators for live price changes (green/red flashing)

**Remaining Work**: ~2-3 hours to implement frontend WebSocket client.

---

## 🟡 IN PROGRESS: Price Alerts (75%)

### Backend (Complete)
- ✅ `price_alerts` collection in Appwrite (appwrite.json updated)
- ✅ `PriceAlert` model with 3 conditions: above/below/crosses
- ✅ `AlertManager` service to monitor and trigger alerts
- ✅ Extended `AppwriteService` with alert CRUD operations
- ✅ Alert API endpoints:
  - `GET /api/alerts` - List all alerts
  - `POST /api/alerts` - Create new alert
  - `DELETE /api/alerts/<id>` - Delete alert
- ✅ Email notifications when alerts trigger
- ✅ SMTP config file: `smtp.config.json`

### Integration (TODO)
- ❌ Add `AlertManager` to trading bot initialization
- ❌ Check alerts in bot's main loop
- ❌ Update `EmailService` to read `smtp.config.json`

### Frontend (TODO)
- ❌ Alert management UI section on dashboard
- ❌ "Create Alert" modal/form
- ❌ List of active alerts with delete buttons
- ❌ Real-time notifications when alerts trigger (via WebSocket)
- ❌ Alert history view (triggered alerts)

**Remaining Work**: ~3-4 hours for bot integration + frontend UI.

---

## ❌ NOT STARTED: Multi-Algorithm Strategy (0%)

This is the most complex feature. Here's the complete implementation plan:

### 1. Strategy Composer Service
**File**: `bot_service/lib/services/strategy_composer.dart`

**Features**:
- Combine signals from multiple algorithms
- 3 composition modes:
  - **Voting** - Require N of M algorithms to agree (e.g., 2 of 3)
  - **Weighted Consensus** - Each algorithm has a weight (e.g., SMA 50%, RSI 30%, Grid 20%)
  - **Unanimous** - All algorithms must agree
- Confidence scoring (average of algorithm confidences)
- Conflict resolution when algorithms disagree

**Implementation**:
```dart
class StrategyComposer {
  final List<TradingAlgorithm> algorithms;
  final CompositionMode mode;
  final Map<String, double> weights; // For weighted mode
  final int requiredVotes; // For voting mode

  TradeSignal? composeSignal(String symbol, double price) {
    // Get signals from all algorithms
    // Apply composition logic
    // Return combined signal or null
  }
}

enum CompositionMode {
  voting,      // N of M must agree
  weighted,    // Weighted average of signals
  unanimous,   // All must agree
}
```

### 2. Update Trading Bot
**File**: `bot_service/lib/bot/trading_bot.dart`

**Changes**:
- Add `StrategyComposer?` parameter
- In `_processSymbol()`, use composer instead of individual algorithms
- Log which algorithms voted for/against each trade

### 3. Configuration
**File**: `bot_service/config/strategy.json`

```json
{
  "enabled": true,
  "mode": "voting",
  "requiredVotes": 2,
  "algorithms": [
    {"name": "SMA Crossover", "enabled": true, "weight": 0.5},
    {"name": "RSI Strategy", "enabled": true, "weight": 0.3},
    {"name": "Grid Trading", "enabled": true, "weight": 0.2}
  ]
}
```

### 4. Frontend UI
**File**: `web_ui/strategy-composer.html` (new section)

**Features**:
- Toggle strategy composer on/off
- Select composition mode (voting/weighted/unanimous)
- For voting: slider to set required votes
- For weighted: sliders to adjust algorithm weights
- Enable/disable individual algorithms
- Real-time visualization showing which algorithms are currently signaling

**Estimated Time**: 1-2 days (8-16 hours)

---

## 🎯 Quick Wins to Complete First

To finish the real-time experience, complete these in order:

### 1. Frontend WebSocket Client (~2 hours)

Create `web_ui/websocket-client.js`:

```javascript
class TradingWebSocket {
  constructor(url) {
    this.url = url;
    this.ws = null;
    this.reconnectDelay = 1000;
    this.maxReconnectDelay = 30000;
    this.handlers = {
      price_update: [],
      trade_update: [],
      alert_triggered: [],
      performance_update: [],
    };
    this.connect();
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectDelay = 1000;
      // Subscribe to watchlist symbols
      this.subscribe(getWatchlistSymbols());
    };

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (this.handlers[data.type]) {
        this.handlers[data.type].forEach(handler => handler(data));
      }
    };

    this.ws.onclose = () => {
      console.log('WebSocket disconnected, reconnecting...');
      setTimeout(() => this.connect(), this.reconnectDelay);
      this.reconnectDelay = Math.min(this.reconnectDelay * 2, this.maxReconnectDelay);
    };
  }

  subscribe(symbols) {
    this.send({action: 'subscribe', symbols});
  }

  on(type, handler) {
    this.handlers[type].push(handler);
  }

  send(data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }
}

// Initialize
const ws = new TradingWebSocket('ws://localhost:3000/ws');

// Listen for price updates
ws.on('price_update', (data) => {
  updatePriceDisplay(data.symbol, data.price, data.changePercent);
});

// Listen for trade updates
ws.on('trade_update', (data) => {
  addTradeToTable(data.data);
  updatePerformanceCharts();
});

// Listen for alert triggers
ws.on('alert_triggered', (data) => {
  showAlertNotification(data.data);
});
```

### 2. Alert Management UI (~2 hours)

Add to `web_ui/index.html` after performance section:

```html
<div class="alerts-section">
  <div class="section-header">
    <h2><i class="fas fa-bell"></i> Price Alerts</h2>
    <button class="btn-primary" onclick="openCreateAlertModal()">
      <i class="fas fa-plus"></i> Create Alert
    </button>
  </div>

  <div class="alerts-list" id="alertsList">
    <!-- Populated by JavaScript -->
  </div>
</div>

<!-- Create Alert Modal -->
<div id="createAlertModal" class="modal">
  <div class="modal-content">
    <h2>Create Price Alert</h2>
    <form id="createAlertForm" onsubmit="createAlert(event)">
      <select id="alertSymbol" required>
        <!-- Populated from watchlist -->
      </select>
      <select id="alertCondition" required>
        <option value="above">Price goes above</option>
        <option value="below">Price goes below</option>
        <option value="crosses">Price crosses</option>
      </select>
      <input type="number" id="alertPrice" step="0.01" required placeholder="Target Price">
      <textarea id="alertMessage" placeholder="Optional message"></textarea>
      <button type="submit" class="btn-primary">Create Alert</button>
    </form>
  </div>
</div>
```

Create `web_ui/alerts.js`:

```javascript
// Load alerts
async function loadAlerts() {
  const response = await fetch('http://localhost:3000/api/alerts');
  const alerts = await response.json();
  renderAlerts(alerts);
}

// Create alert
async function createAlert(event) {
  event.preventDefault();
  const data = {
    symbol: document.getElementById('alertSymbol').value,
    condition: document.getElementById('alertCondition').value,
    targetPrice: parseFloat(document.getElementById('alertPrice').value),
    message: document.getElementById('alertMessage').value,
  };

  await fetch('http://localhost:3000/api/alerts', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(data),
  });

  closeCreateAlertModal();
  loadAlerts();
}

// Delete alert
async function deleteAlert(id) {
  await fetch(`http://localhost:3000/api/alerts/${id}`, {method: 'DELETE'});
  loadAlerts();
}

// Real-time notification
ws.on('alert_triggered', (data) => {
  showNotification('🔔 Price Alert',
    `${data.data.symbol} ${data.data.condition} $${data.data.targetPrice}`
  );
  loadAlerts(); // Refresh list
});
```

### 3. Integrate AlertManager into Bot (~1 hour)

Update `bot_service/bin/server.dart`:

```dart
// After initializing emailService
final alertManager = AlertManager(
  appwrite: appwrite,
  emailService: emailService,
  userId: env['BOT_USER_ID'] ?? 'default_user',
);
await alertManager.loadAlerts();
log.info('✅ Alert manager initialized');

// Pass to bot
final bot = TradingBot(
  // ... existing params ...
  alertManager: alertManager,
);
```

Update `bot_service/lib/bot/trading_bot.dart`:

Add `AlertManager?` field and in `_runTradingCycle()`:

```dart
// After checking risk management
if (alertManager != null && _watchlist.isNotEmpty) {
  await _checkAlerts();
}

// Add new method
Future<void> _checkAlerts() async {
  final priceMap = <String, double>{};
  for (final item in _watchlist) {
    try {
      final ticker = await binance.spot.market.get24HrTicker(item.symbol);
      priceMap[item.symbol] = double.parse(ticker['lastPrice']);
    } catch (e) {}
  }
  await alertManager!.checkAlerts(priceMap);
}
```

---

## Summary

**Completed**: Performance Charts backend + frontend (needs WebSocket upgrade)
**75% Done**: Price Alerts backend (needs UI + bot integration)
**60% Done**: WebSocket infrastructure (needs frontend client)
**0% Done**: Multi-Algorithm Strategy

**Total Remaining Work**: ~8-10 hours to complete all real-time features + alerts
**Multi-Algorithm**: Additional 8-16 hours

---

## Next Steps (Priority Order)

1. **Implement WebSocket frontend client** (2 hours) - Makes everything real-time
2. **Build Alert Management UI** (2 hours) - Completes price alerts feature
3. **Integrate AlertManager into bot** (1 hour) - Enables alert monitoring
4. **Multi-Algorithm Strategy** (1-2 days) - Complex voting/weighting system

After completing 1-3, you'll have a fully real-time platform with live charts and price alerts!
