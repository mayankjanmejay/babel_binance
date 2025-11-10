// Alert Management Module
// Handles creation, deletion, and display of price alerts

const API_BASE = window.location.hostname === 'localhost'
  ? 'http://localhost:3000/api'
  : `${window.location.protocol}//${window.location.host}/api`;

let activeAlerts = [];

/**
 * Initialize alerts module
 */
async function initAlerts() {
  await loadAlerts();
  populateAlertSymbolSelect();

  // Real-time alert triggers via WebSocket
  if (window.tradingWS) {
    window.tradingWS.on('alert_triggered', handleAlertTriggered);
  }
}

/**
 * Load all alerts from API
 */
async function loadAlerts() {
  try {
    const response = await fetch(`${API_BASE}/alerts`);
    const alerts = await response.json();

    activeAlerts = alerts;
    renderAlerts(alerts);

    console.log(`Loaded ${alerts.length} alerts`);
  } catch (error) {
    console.error('Failed to load alerts:', error);
    showError('Failed to load alerts');
  }
}

/**
 * Render alerts list
 */
function renderAlerts(alerts) {
  const container = document.getElementById('alertsList');
  if (!container) return;

  if (alerts.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <i class="fas fa-bell-slash"></i>
        <p>No active alerts</p>
        <button class="btn-primary" onclick="openCreateAlertModal()">
          <i class="fas fa-plus"></i> Create Your First Alert
        </button>
      </div>
    `;
    return;
  }

  // Separate active and triggered alerts
  const active = alerts.filter(a => a.active && !a.triggered);
  const triggered = alerts.filter(a => a.triggered);

  let html = '';

  if (active.length > 0) {
    html += '<h3>Active Alerts</h3><div class="alerts-grid">';
    active.forEach(alert => {
      html += renderAlertCard(alert, 'active');
    });
    html += '</div>';
  }

  if (triggered.length > 0) {
    html += '<h3>Recently Triggered</h3><div class="alerts-grid">';
    triggered.forEach(alert => {
      html += renderAlertCard(alert, 'triggered');
    });
    html += '</div>';
  }

  container.innerHTML = html;
}

/**
 * Render individual alert card
 */
function renderAlertCard(alert, status) {
  const conditionIcon = {
    'above': 'arrow-up',
    'below': 'arrow-down',
    'crosses': 'exchange-alt'
  }[alert.condition] || 'bell';

  const conditionText = {
    'above': 'goes above',
    'below': 'goes below',
    'crosses': 'crosses'
  }[alert.condition] || alert.condition;

  const triggeredTime = alert.triggeredAt
    ? new Date(alert.triggeredAt).toLocaleString()
    : '';

  return `
    <div class="alert-card ${status}" data-alert-id="${alert.$id || alert.id}">
      <div class="alert-icon ${alert.condition}">
        <i class="fas fa-${conditionIcon}"></i>
      </div>
      <div class="alert-details">
        <div class="alert-symbol">${alert.symbol}</div>
        <div class="alert-condition">
          ${conditionText} <strong>$${parseFloat(alert.targetPrice || alert.target_price).toFixed(2)}</strong>
        </div>
        ${alert.message ? `<div class="alert-message">${alert.message}</div>` : ''}
        ${status === 'triggered' ? `<div class="alert-triggered-time">Triggered: ${triggeredTime}</div>` : ''}
      </div>
      <div class="alert-actions">
        ${status === 'active' ? `
          <button class="btn-icon btn-delete" onclick="deleteAlert('${alert.$id || alert.id}')" title="Delete alert">
            <i class="fas fa-trash"></i>
          </button>
        ` : ''}
      </div>
    </div>
  `;
}

/**
 * Open create alert modal
 */
function openCreateAlertModal() {
  const modal = document.getElementById('createAlertModal');
  if (modal) {
    modal.style.display = 'flex';
    populateAlertSymbolSelect();
  }
}

/**
 * Close create alert modal
 */
function closeCreateAlertModal() {
  const modal = document.getElementById('createAlertModal');
  if (modal) {
    modal.style.display = 'none';
    document.getElementById('createAlertForm').reset();
  }
}

/**
 * Populate symbol select with watchlist symbols
 */
async function populateAlertSymbolSelect() {
  const select = document.getElementById('alertSymbol');
  if (!select) return;

  try {
    const response = await fetch(`${API_BASE}/watchlist`);
    const watchlist = await response.json();

    select.innerHTML = watchlist.map(item =>
      `<option value="${item.symbol}">${item.symbol}</option>`
    ).join('');

    if (watchlist.length === 0) {
      select.innerHTML = '<option value="">No symbols in watchlist</option>';
    }
  } catch (error) {
    console.error('Failed to load watchlist for alerts:', error);
    select.innerHTML = '<option value="">Error loading symbols</option>';
  }
}

/**
 * Create new alert
 */
async function createAlert(event) {
  event.preventDefault();

  const symbol = document.getElementById('alertSymbol').value;
  const condition = document.getElementById('alertCondition').value;
  const targetPrice = parseFloat(document.getElementById('alertPrice').value);
  const message = document.getElementById('alertMessage').value;

  if (!symbol || !condition || !targetPrice) {
    showError('Please fill in all required fields');
    return;
  }

  try {
    const response = await fetch(`${API_BASE}/alerts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        symbol,
        condition,
        targetPrice,
        message,
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to create alert');
    }

    showSuccess('Alert created successfully!');
    closeCreateAlertModal();
    await loadAlerts();

  } catch (error) {
    console.error('Failed to create alert:', error);
    showError('Failed to create alert');
  }
}

/**
 * Delete alert
 */
async function deleteAlert(alertId) {
  if (!confirm('Are you sure you want to delete this alert?')) {
    return;
  }

  try {
    const response = await fetch(`${API_BASE}/alerts/${alertId}`, {
      method: 'DELETE',
    });

    if (!response.ok) {
      throw new Error('Failed to delete alert');
    }

    showSuccess('Alert deleted');
    await loadAlerts();

  } catch (error) {
    console.error('Failed to delete alert:', error);
    showError('Failed to delete alert');
  }
}

/**
 * Handle real-time alert trigger from WebSocket
 */
function handleAlertTriggered(data) {
  console.log('Alert triggered:', data);
  loadAlerts(); // Refresh alerts list
}

/**
 * Check if current price triggers any alerts (client-side preview)
 */
function checkPriceAlerts(priceData) {
  const { symbol, price } = priceData;
  const currentPrice = parseFloat(price);

  activeAlerts.forEach(alert => {
    if (alert.symbol !== symbol || alert.triggered || !alert.active) return;

    const targetPrice = parseFloat(alert.targetPrice || alert.target_price);
    let shouldAlert = false;

    switch (alert.condition) {
      case 'above':
        shouldAlert = currentPrice >= targetPrice;
        break;
      case 'below':
        shouldAlert = currentPrice <= targetPrice;
        break;
      case 'crosses':
        // This is approximate - server handles the actual trigger
        shouldAlert = Math.abs(currentPrice - targetPrice) / targetPrice < 0.001;
        break;
    }

    if (shouldAlert) {
      // Visual indication that alert is about to trigger
      const card = document.querySelector(`[data-alert-id="${alert.$id || alert.id}"]`);
      if (card) {
        card.classList.add('pending-trigger');
      }
    }
  });
}

/**
 * Show success message
 */
function showSuccess(message) {
  const toast = document.createElement('div');
  toast.className = 'toast success';
  toast.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
  document.body.appendChild(toast);

  setTimeout(() => {
    toast.classList.add('show');
  }, 100);

  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

/**
 * Show error message
 */
function showError(message) {
  const toast = document.createElement('div');
  toast.className = 'toast error';
  toast.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
  document.body.appendChild(toast);

  setTimeout(() => {
    toast.classList.add('show');
  }, 100);

  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initAlerts);
} else {
  initAlerts();
}

// Expose functions globally
window.openCreateAlertModal = openCreateAlertModal;
window.closeCreateAlertModal = closeCreateAlertModal;
window.createAlert = createAlert;
window.deleteAlert = deleteAlert;
window.loadAlerts = loadAlerts;
window.checkPriceAlerts = checkPriceAlerts;
