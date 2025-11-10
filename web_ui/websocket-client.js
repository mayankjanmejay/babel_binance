// WebSocket Real-Time Client
// Handles all real-time data streams - NO POLLING!

class TradingWebSocket {
  constructor() {
    this.ws = null;
    this.reconnectDelay = 1000;
    this.maxReconnectDelay = 30000;
    this.reconnectAttempts = 0;
    this.subscribedSymbols = new Set();

    // Event handlers
    this.handlers = {
      connected: [],
      disconnected: [],
      price_update: [],
      trade_update: [],
      alert_triggered: [],
      performance_update: [],
      heartbeat: [],
      error: [],
    };

    this.connect();
  }

  connect() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.hostname;
    const port = '3000'; // API server port
    this.ws = new WebSocket(`${protocol}//${host}:${port}/ws`);

    this.ws.onopen = () => {
      console.log('✅ WebSocket connected');
      this.reconnectDelay = 1000;
      this.reconnectAttempts = 0;
      this.trigger('connected');

      // Re-subscribe to symbols after reconnect
      if (this.subscribedSymbols.size > 0) {
        this.subscribe(Array.from(this.subscribedSymbols));
      }
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        this.handleMessage(data);
      } catch (e) {
        console.error('Failed to parse WebSocket message:', e);
      }
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      this.trigger('error', error);
    };

    this.ws.onclose = () => {
      console.log('WebSocket disconnected');
      this.trigger('disconnected');
      this.scheduleReconnect();
    };
  }

  handleMessage(data) {
    const { type } = data;

    switch (type) {
      case 'connected':
        console.log('Server confirmed connection');
        break;

      case 'price_update':
        this.trigger('price_update', data);
        break;

      case 'trade_update':
        this.trigger('trade_update', data);
        break;

      case 'alert_triggered':
        this.trigger('alert_triggered', data);
        break;

      case 'performance_update':
        this.trigger('performance_update', data);
        break;

      case 'heartbeat':
        this.trigger('heartbeat', data);
        break;

      case 'pong':
        // Response to ping
        break;

      default:
        console.warn('Unknown message type:', type);
    }
  }

  scheduleReconnect() {
    this.reconnectAttempts++;
    const delay = Math.min(
      this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1),
      this.maxReconnectDelay
    );

    console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})...`);

    setTimeout(() => {
      this.connect();
    }, delay);
  }

  subscribe(symbols) {
    if (!Array.isArray(symbols)) {
      symbols = [symbols];
    }

    symbols.forEach(s => this.subscribedSymbols.add(s.toUpperCase()));

    this.send({
      action: 'subscribe',
      symbols: symbols.map(s => s.toUpperCase()),
    });

    console.log('Subscribed to:', symbols);
  }

  unsubscribe(symbols) {
    if (!Array.isArray(symbols)) {
      symbols = [symbols];
    }

    symbols.forEach(s => this.subscribedSymbols.delete(s.toUpperCase()));

    this.send({
      action: 'unsubscribe',
      symbols: symbols.map(s => s.toUpperCase()),
    });

    console.log('Unsubscribed from:', symbols);
  }

  send(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    } else {
      console.warn('WebSocket not connected, cannot send:', data);
    }
  }

  ping() {
    this.send({ action: 'ping' });
  }

  on(event, handler) {
    if (this.handlers[event]) {
      this.handlers[event].push(handler);
    } else {
      console.warn('Unknown event type:', event);
    }
  }

  off(event, handler) {
    if (this.handlers[event]) {
      const index = this.handlers[event].indexOf(handler);
      if (index > -1) {
        this.handlers[event].splice(index, 1);
      }
    }
  }

  trigger(event, data) {
    if (this.handlers[event]) {
      this.handlers[event].forEach(handler => {
        try {
          handler(data);
        } catch (e) {
          console.error('Error in event handler:', e);
        }
      });
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  getStatus() {
    if (!this.ws) return 'disconnected';

    switch (this.ws.readyState) {
      case WebSocket.CONNECTING:
        return 'connecting';
      case WebSocket.OPEN:
        return 'connected';
      case WebSocket.CLOSING:
        return 'closing';
      case WebSocket.CLOSED:
        return 'disconnected';
      default:
        return 'unknown';
    }
  }
}

// Global WebSocket instance
const tradingWS = new TradingWebSocket();

// Real-time price updates
tradingWS.on('price_update', (data) => {
  updatePriceDisplay(data);
  checkPriceAlerts(data);
});

// Real-time trade updates
tradingWS.on('trade_update', (data) => {
  addTradeToTable(data.data);
  updatePerformanceChartsRealtime(data.data);
  showTradeNotification(data.data);
});

// Real-time alert triggers
tradingWS.on('alert_triggered', (data) => {
  showAlertNotification(data.data);
  playAlertSound();
  loadAlerts(); // Refresh alerts list
});

// Performance updates
tradingWS.on('performance_update', (data) => {
  updatePerformanceSummary(data.data);
});

// Connection status
tradingWS.on('connected', () => {
  updateConnectionStatus('connected');
});

tradingWS.on('disconnected', () => {
  updateConnectionStatus('disconnected');
});

// Update connection status indicator
function updateConnectionStatus(status) {
  const statusDot = document.getElementById('statusDot');
  const statusText = document.getElementById('statusText');

  if (status === 'connected') {
    statusDot.className = 'status-dot connected';
    statusText.textContent = 'Connected';
  } else {
    statusDot.className = 'status-dot disconnected';
    statusText.textContent = 'Disconnected';
  }
}

// Update price display with real-time data
function updatePriceDisplay(data) {
  const { symbol, price, changePercent, high, low, volume } = data;

  // Update in watchlist table
  const row = document.querySelector(`tr[data-symbol="${symbol}"]`);
  if (row) {
    const priceCell = row.querySelector('.price');
    const changeCell = row.querySelector('.change');

    if (priceCell) {
      const oldPrice = parseFloat(priceCell.textContent.replace(/[^0-9.]/g, ''));
      priceCell.textContent = `$${parseFloat(price).toFixed(2)}`;

      // Flash animation
      if (oldPrice < parseFloat(price)) {
        priceCell.classList.add('price-up');
        setTimeout(() => priceCell.classList.remove('price-up'), 1000);
      } else if (oldPrice > parseFloat(price)) {
        priceCell.classList.add('price-down');
        setTimeout(() => priceCell.classList.remove('price-down'), 1000);
      }
    }

    if (changeCell) {
      const change = parseFloat(changePercent);
      changeCell.textContent = `${change >= 0 ? '+' : ''}${change.toFixed(2)}%`;
      changeCell.className = `change ${change >= 0 ? 'positive' : 'negative'}`;
    }
  }
}

// Update performance charts in real-time
function updatePerformanceChartsRealtime(trade) {
  // Recalculate and update charts without full reload
  // This gets called every time a trade executes

  // For now, just trigger a refresh (we'll optimize this later)
  if (typeof refreshPerformanceCharts === 'function') {
    refreshPerformanceCharts();
  }
}

// Show trade notification
function showTradeNotification(trade) {
  const { symbol, side, quantity, price } = trade;

  const notification = document.createElement('div');
  notification.className = `notification trade-notification ${side.toLowerCase()}`;
  notification.innerHTML = `
    <div class="notification-icon">
      <i class="fas fa-${side === 'BUY' ? 'arrow-up' : 'arrow-down'}"></i>
    </div>
    <div class="notification-content">
      <strong>${side} ${symbol}</strong>
      <span>${quantity} @ $${parseFloat(price).toFixed(2)}</span>
    </div>
  `;

  document.body.appendChild(notification);

  setTimeout(() => {
    notification.classList.add('show');
  }, 100);

  setTimeout(() => {
    notification.classList.remove('show');
    setTimeout(() => notification.remove(), 300);
  }, 5000);
}

// Show alert notification
function showAlertNotification(alert) {
  const notification = document.createElement('div');
  notification.className = 'notification alert-notification';
  notification.innerHTML = `
    <div class="notification-icon">
      <i class="fas fa-bell"></i>
    </div>
    <div class="notification-content">
      <strong>🔔 Price Alert Triggered!</strong>
      <span>${alert.symbol} ${alert.condition} $${parseFloat(alert.targetPrice).toFixed(2)}</span>
      ${alert.message ? `<p>${alert.message}</p>` : ''}
    </div>
  `;

  document.body.appendChild(notification);

  setTimeout(() => {
    notification.classList.add('show');
  }, 100);

  setTimeout(() => {
    notification.classList.remove('show');
    setTimeout(() => notification.remove(), 300);
  }, 8000);
}

// Play alert sound
function playAlertSound() {
  // Create a simple beep sound
  const audioContext = new (window.AudioContext || window.webkitAudioContext)();
  const oscillator = audioContext.createOscillator();
  const gainNode = audioContext.createGain();

  oscillator.connect(gainNode);
  gainNode.connect(audioContext.destination);

  oscillator.frequency.value = 800;
  oscillator.type = 'sine';

  gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);

  oscillator.start(audioContext.currentTime);
  oscillator.stop(audioContext.currentTime + 0.5);
}

// Export for use in other modules
window.tradingWS = tradingWS;
