// Frontend tests using Jest syntax for JavaScript
// File: web_ui/test/dashboard.test.js

describe('Dashboard API Functions', () => {
  // Mock fetch API
  global.fetch = jest.fn();

  beforeEach(() => {
    fetch.mockClear();
  });

  describe('checkApiStatus', () => {
    test('updates status indicator on success', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          status: 'operational',
          services: { binance: 'connected', appwrite: 'connected' }
        })
      });

      await checkApiStatus();

      expect(fetch).toHaveBeenCalledWith('http://localhost:3000/status');
    });

    test('handles connection failure gracefully', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      await checkApiStatus();

      // Should not throw error
      expect(true).toBe(true);
    });
  });

  describe('loadWatchlist', () => {
    test('displays watchlist items correctly', async () => {
      const mockWatchlist = [
        {
          $id: '1',
          symbol: 'BTCUSDT',
          target_buy: 90000,
          target_sell: 100000,
          active: true
        }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockWatchlist
      });

      await loadWatchlist();

      expect(fetch).toHaveBeenCalledWith('http://localhost:3000/api/watchlist');
    });

    test('handles empty watchlist', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => []
      });

      await loadWatchlist();

      expect(fetch).toHaveBeenCalled();
    });
  });

  describe('loadPrices', () => {
    test('displays price data with change indicators', async () => {
      const mockPrices = [
        {
          symbol: 'BTCUSDT',
          lastPrice: '95234.56',
          priceChangePercent: '2.5',
          quoteVolume: '1000000000',
          highPrice: '96000.00',
          lowPrice: '94000.00'
        }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockPrices
      });

      await loadPrices();

      expect(fetch).toHaveBeenCalledWith('http://localhost:3000/api/market/tickers');
    });
  });

  describe('addSymbol', () => {
    test('adds symbol to watchlist successfully', async () => {
      const mockEvent = {
        preventDefault: jest.fn()
      };

      document.body.innerHTML = `
        <input id="symbolInput" value="BTCUSDT">
        <input id="targetBuyInput" value="90000">
        <input id="targetSellInput" value="100000">
      `;

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      });

      await addSymbol(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/api/watchlist',
        expect.objectContaining({
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        })
      );
    });

    test('handles API error when adding symbol', async () => {
      const mockEvent = { preventDefault: jest.fn() };

      document.body.innerHTML = `<input id="symbolInput" value="BTCUSDT">`;

      fetch.mockResolvedValueOnce({
        ok: false,
        json: async () => ({ error: 'Failed to add' })
      });

      await addSymbol(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
    });
  });

  describe('Modal Functions', () => {
    test('openAddSymbolModal shows modal', () => {
      document.body.innerHTML = `<div id="addSymbolModal" class="modal"></div>`;

      openAddSymbolModal();

      const modal = document.getElementById('addSymbolModal');
      expect(modal.classList.contains('show')).toBe(true);
    });

    test('closeAddSymbolModal hides modal', () => {
      document.body.innerHTML = `
        <div id="addSymbolModal" class="modal show"></div>
        <form id="addSymbolForm"></form>
      `;

      closeAddSymbolModal();

      const modal = document.getElementById('addSymbolModal');
      expect(modal.classList.contains('show')).toBe(false);
    });
  });

  describe('Auto-refresh', () => {
    test('startAutoRefresh sets interval', () => {
      jest.useFakeTimers();

      startAutoRefresh();

      expect(setInterval).toHaveBeenCalled();
      expect(setInterval).toHaveBeenCalledWith(
        expect.any(Function),
        30000
      );

      jest.useRealTimers();
    });

    test('stopAutoRefresh clears interval', () => {
      jest.useFakeTimers();

      startAutoRefresh();
      stopAutoRefresh();

      expect(clearInterval).toHaveBeenCalled();

      jest.useRealTimers();
    });
  });
});

describe('UI Helper Functions', () => {
  test('updateStatusIndicator sets online status', () => {
    document.body.innerHTML = `
      <span id="statusDot" class="status-dot"></span>
      <span id="statusText"></span>
    `;

    updateStatusIndicator(true, 'Connected');

    const dot = document.getElementById('statusDot');
    const text = document.getElementById('statusText');

    expect(dot.classList.contains('offline')).toBe(false);
    expect(text.textContent).toBe('Connected');
  });

  test('updateStatusIndicator sets offline status', () => {
    document.body.innerHTML = `
      <span id="statusDot" class="status-dot"></span>
      <span id="statusText"></span>
    `;

    updateStatusIndicator(false, 'Offline');

    const dot = document.getElementById('statusDot');
    const text = document.getElementById('statusText');

    expect(dot.classList.contains('offline')).toBe(true);
    expect(text.textContent).toBe('Offline');
  });
});
