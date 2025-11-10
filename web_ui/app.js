// ============================================================================
// CONFIGURATION
// ============================================================================

const API_BASE_URL = 'http://localhost:3000';

// ============================================================================
// INITIALIZATION
// ============================================================================

document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Crypto Trading Bot Dashboard initialized (Real-Time Mode)');

    // Check API status
    await checkApiStatus();

    // Load initial data ONCE - WebSocket handles all updates from here
    await loadDashboardData();
});

// ============================================================================
// API STATUS
// ============================================================================

async function checkApiStatus() {
    try {
        const response = await fetch(`${API_BASE_URL}/status`);
        const data = await response.json();

        updateStatusIndicator(true, 'Connected');
        console.log('✅ API Status:', data);
    } catch (error) {
        updateStatusIndicator(false, 'Offline');
        console.error('❌ API connection failed:', error);
    }
}

function updateStatusIndicator(isOnline, text) {
    const statusDot = document.getElementById('statusDot');
    const statusText = document.getElementById('statusText');

    if (isOnline) {
        statusDot.classList.remove('offline');
        statusText.textContent = text;
    } else {
        statusDot.classList.add('offline');
        statusText.textContent = text;
    }
}

// ============================================================================
// LOAD DASHBOARD DATA
// ============================================================================

async function loadDashboardData() {
    await Promise.all([
        loadStats(),
        loadWatchlist(),
        loadPrices(),
        loadTrades(),
    ]);
}

// ============================================================================
// STATS
// ============================================================================

async function loadStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/trades/stats`);
        const data = await response.json();

        document.getElementById('totalTrades').textContent = data.total_trades || 0;
        document.getElementById('buyTrades').textContent = data.buy_trades || 0;
        document.getElementById('sellTrades').textContent = data.sell_trades || 0;
        document.getElementById('totalVolume').textContent = `$${(data.total_volume || 0).toFixed(2)}`;
    } catch (error) {
        console.error('Failed to load stats:', error);
    }
}

// ============================================================================
// WATCHLIST
// ============================================================================

async function loadWatchlist() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/watchlist`);
        const data = await response.json();

        const container = document.getElementById('watchlistTable');

        if (data.length === 0) {
            container.innerHTML = '<p class="loading">No symbols in watchlist. Add some to get started!</p>';
            // Unsubscribe from all if watchlist is empty
            if (window.tradingWS) {
                window.tradingWS.subscribedSymbols.forEach(symbol => {
                    window.tradingWS.unsubscribe(symbol);
                });
            }
            return;
        }

        // Extract symbols and subscribe to WebSocket streams
        const symbols = data.map(item => item.symbol);
        if (window.tradingWS) {
            window.tradingWS.subscribe(symbols);
            console.log('📡 Subscribed to real-time price streams:', symbols);
        }

        // Render watchlist table with price columns
        let html = `
            <table>
                <thead>
                    <tr>
                        <th>Symbol</th>
                        <th>Current Price</th>
                        <th>24h Change</th>
                        <th>Target Buy</th>
                        <th>Target Sell</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
        `;

        data.forEach(item => {
            html += `
                <tr data-symbol="${item.symbol}">
                    <td><strong>${item.symbol}</strong></td>
                    <td class="price">Loading...</td>
                    <td class="change">-</td>
                    <td>${item.target_buy ? '$' + item.target_buy : '-'}</td>
                    <td>${item.target_sell ? '$' + item.target_sell : '-'}</td>
                    <td>
                        <span class="badge ${item.active ? 'badge-success' : 'badge-danger'}">
                            ${item.active ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                    <td>
                        <button class="btn-danger" onclick="removeFromWatchlist('${item.$id || item.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        });

        html += '</tbody></table>';
        container.innerHTML = html;
    } catch (error) {
        console.error('Failed to load watchlist:', error);
        document.getElementById('watchlistTable').innerHTML =
            '<p class="error">Failed to load watchlist. Please check your connection.</p>';
    }
}

async function removeFromWatchlist(id) {
    if (!confirm('Are you sure you want to remove this symbol?')) return;

    try {
        await fetch(`${API_BASE_URL}/api/watchlist/${id}`, {
            method: 'DELETE',
        });

        await loadWatchlist();
        await loadPrices();
    } catch (error) {
        console.error('Failed to remove symbol:', error);
        alert('Failed to remove symbol. Please try again.');
    }
}

// ============================================================================
// LIVE PRICES
// ============================================================================

async function loadPrices() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/market/tickers`);
        const data = await response.json();

        const container = document.getElementById('pricesTable');

        if (data.length === 0) {
            container.innerHTML = '<p class="loading">No price data available</p>';
            return;
        }

        let html = `
            <table>
                <thead>
                    <tr>
                        <th>Symbol</th>
                        <th>Price</th>
                        <th>24h Change</th>
                        <th>24h Volume</th>
                        <th>High</th>
                        <th>Low</th>
                    </tr>
                </thead>
                <tbody>
        `;

        data.forEach(ticker => {
            const priceChange = parseFloat(ticker.priceChangePercent || 0);
            const priceClass = priceChange >= 0 ? 'price-up' : 'price-down';
            const arrow = priceChange >= 0 ? '▲' : '▼';

            html += `
                <tr>
                    <td><strong>${ticker.symbol}</strong></td>
                    <td>$${parseFloat(ticker.lastPrice).toFixed(2)}</td>
                    <td class="${priceClass}">
                        ${arrow} ${Math.abs(priceChange).toFixed(2)}%
                    </td>
                    <td>$${parseFloat(ticker.quoteVolume).toLocaleString()}</td>
                    <td>$${parseFloat(ticker.highPrice).toFixed(2)}</td>
                    <td>$${parseFloat(ticker.lowPrice).toFixed(2)}</td>
                </tr>
            `;
        });

        html += '</tbody></table>';
        container.innerHTML = html;
    } catch (error) {
        console.error('Failed to load prices:', error);
        document.getElementById('pricesTable').innerHTML =
            '<p class="error">Failed to load prices. Please check your connection.</p>';
    }
}

async function refreshPrices() {
    await loadPrices();
}

// ============================================================================
// TRADES
// ============================================================================

async function loadTrades() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/trades`);
        const data = await response.json();

        const container = document.getElementById('tradesTable');

        if (data.length === 0) {
            container.innerHTML = '<p class="loading">No trades yet</p>';
            return;
        }

        let html = `
            <table>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Symbol</th>
                        <th>Side</th>
                        <th>Quantity</th>
                        <th>Price</th>
                        <th>Total</th>
                        <th>Algorithm</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
        `;

        data.slice(0, 20).forEach(trade => {
            const timestamp = new Date(trade.timestamp).toLocaleString();
            const sideClass = trade.side === 'BUY' ? 'badge-success' : 'badge-danger';

            html += `
                <tr>
                    <td>${timestamp}</td>
                    <td><strong>${trade.symbol}</strong></td>
                    <td><span class="badge ${sideClass}">${trade.side}</span></td>
                    <td>${trade.quantity}</td>
                    <td>$${trade.price.toFixed(2)}</td>
                    <td>$${trade.total_value.toFixed(2)}</td>
                    <td>${trade.algorithm_name}</td>
                    <td><span class="badge badge-info">${trade.status}</span></td>
                </tr>
            `;
        });

        html += '</tbody></table>';
        container.innerHTML = html;
    } catch (error) {
        console.error('Failed to load trades:', error);
        document.getElementById('tradesTable').innerHTML =
            '<p class="error">Failed to load trades. Please check your connection.</p>';
    }
}

// ============================================================================
// ADD SYMBOL MODAL
// ============================================================================

function openAddSymbolModal() {
    document.getElementById('addSymbolModal').classList.add('show');
}

function closeAddSymbolModal() {
    document.getElementById('addSymbolModal').classList.remove('show');
    document.getElementById('addSymbolForm').reset();
}

async function addSymbol(event) {
    event.preventDefault();

    const symbol = document.getElementById('symbolInput').value.toUpperCase();
    const targetBuy = document.getElementById('targetBuyInput').value;
    const targetSell = document.getElementById('targetSellInput').value;

    try {
        const response = await fetch(`${API_BASE_URL}/api/watchlist`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                symbol,
                target_buy: targetBuy ? parseFloat(targetBuy) : null,
                target_sell: targetSell ? parseFloat(targetSell) : null,
            }),
        });

        if (response.ok) {
            closeAddSymbolModal();
            await loadWatchlist();
            await loadPrices();
        } else {
            alert('Failed to add symbol. Please try again.');
        }
    } catch (error) {
        console.error('Failed to add symbol:', error);
        alert('Failed to add symbol. Please check your connection.');
    }
}

// ============================================================================
// REAL-TIME UPDATE HANDLERS
// ============================================================================

// Add trade to table in real-time when WebSocket receives new trade
function addTradeToTable(trade) {
    const container = document.getElementById('tradesTable');
    if (!container) return;

    // Check if table exists
    let table = container.querySelector('table');
    if (!table) {
        // Create table if it doesn't exist
        container.innerHTML = `
            <table>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Symbol</th>
                        <th>Side</th>
                        <th>Quantity</th>
                        <th>Price</th>
                        <th>Total</th>
                        <th>Algorithm</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="tradesTableBody">
                </tbody>
            </table>
        `;
        table = container.querySelector('table');
    }

    const tbody = table.querySelector('tbody');
    if (!tbody) return;

    // Create new row
    const timestamp = new Date(trade.timestamp).toLocaleString();
    const row = document.createElement('tr');
    row.className = 'new-trade'; // For animation
    row.innerHTML = `
        <td>${timestamp}</td>
        <td><strong>${trade.symbol}</strong></td>
        <td>
            <span class="badge ${trade.side === 'BUY' ? 'badge-success' : 'badge-danger'}">
                ${trade.side}
            </span>
        </td>
        <td>${parseFloat(trade.quantity).toFixed(6)}</td>
        <td>$${parseFloat(trade.price).toFixed(2)}</td>
        <td>$${parseFloat(trade.total_value || trade.totalValue || 0).toFixed(2)}</td>
        <td>${trade.algorithm_name || trade.algorithmName}</td>
        <td><span class="badge badge-success">${trade.status}</span></td>
    `;

    // Add to top of table
    tbody.insertBefore(row, tbody.firstChild);

    // Fade in animation
    setTimeout(() => {
        row.classList.remove('new-trade');
    }, 100);

    // Keep only last 50 trades
    while (tbody.children.length > 50) {
        tbody.removeChild(tbody.lastChild);
    }
}

// Update stats in real-time when a trade happens
function updateStatsOnTrade(trade) {
    try {
        // Get current values
        const totalTradesEl = document.getElementById('totalTrades');
        const buyTradesEl = document.getElementById('buyTrades');
        const sellTradesEl = document.getElementById('sellTrades');
        const totalVolumeEl = document.getElementById('totalVolume');

        // Increment totals
        const totalTrades = parseInt(totalTradesEl.textContent) + 1;
        totalTradesEl.textContent = totalTrades;

        if (trade.side === 'BUY') {
            const buyTrades = parseInt(buyTradesEl.textContent) + 1;
            buyTradesEl.textContent = buyTrades;
        } else {
            const sellTrades = parseInt(sellTradesEl.textContent) + 1;
            sellTradesEl.textContent = sellTrades;
        }

        // Update volume
        const currentVolume = parseFloat(totalVolumeEl.textContent.replace(/[$,]/g, ''));
        const newVolume = currentVolume + parseFloat(trade.total_value || trade.totalValue || 0);
        totalVolumeEl.textContent = `$${newVolume.toFixed(2)}`;

        // Flash animation
        [totalTradesEl, buyTradesEl, sellTradesEl, totalVolumeEl].forEach(el => {
            el.classList.add('stat-updated');
            setTimeout(() => el.classList.remove('stat-updated'), 500);
        });
    } catch (error) {
        console.error('Failed to update stats:', error);
    }
}
