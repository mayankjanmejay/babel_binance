// Performance Charts Module
// Uses Chart.js for visualizations

const API_BASE = 'http://localhost:3000/api';

let plChart = null;
let winRateChart = null;
let algoChart = null;

/**
 * Initialize all performance charts
 */
async function initPerformanceCharts() {
    try {
        await Promise.all([
            loadPerformanceSummary(),
            loadPLChart(),
            loadWinRateChart(),
            loadAlgorithmChart(),
        ]);

        console.log('✅ Performance charts loaded');
    } catch (error) {
        console.error('Failed to load performance charts:', error);
    }
}

/**
 * Load and display performance summary metrics
 */
async function loadPerformanceSummary() {
    try {
        const response = await fetch(`${API_BASE}/performance/summary`);
        const data = await response.json();

        // Update summary cards
        document.getElementById('totalPL').textContent = formatCurrency(data.total_profit_loss);
        document.getElementById('winRate').textContent = formatPercent(data.win_rate);
        document.getElementById('avgProfit').textContent = formatCurrency(data.avg_profit);
        document.getElementById('avgLoss').textContent = formatCurrency(data.avg_loss);
        document.getElementById('totalWins').textContent = data.total_wins;
        document.getElementById('totalLosses').textContent = data.total_losses;

        // Color code P/L
        const plElement = document.getElementById('totalPL');
        if (data.total_profit_loss > 0) {
            plElement.classList.add('positive');
            plElement.classList.remove('negative');
        } else if (data.total_profit_loss < 0) {
            plElement.classList.add('negative');
            plElement.classList.remove('positive');
        }

    } catch (error) {
        console.error('Failed to load performance summary:', error);
    }
}

/**
 * Load and display P&L over time chart
 */
async function loadPLChart() {
    try {
        const response = await fetch(`${API_BASE}/performance/chart`);
        const data = await response.json();

        if (data.length === 0) {
            document.getElementById('plChart').innerHTML =
                '<p class="no-data">No trade data available yet</p>';
            return;
        }

        const ctx = document.getElementById('plChart').getContext('2d');

        // Destroy existing chart if it exists
        if (plChart) {
            plChart.destroy();
        }

        plChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.map(d => new Date(d.timestamp).toLocaleDateString()),
                datasets: [
                    {
                        label: 'Cumulative P&L',
                        data: data.map(d => d.cumulative_pl),
                        borderColor: 'rgb(99, 102, 241)',
                        backgroundColor: 'rgba(99, 102, 241, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4,
                    },
                    {
                        label: 'Individual Trade P&L',
                        data: data.map(d => d.profit_loss),
                        borderColor: 'rgba(156, 163, 175, 0.5)',
                        backgroundColor: data.map(d =>
                            d.profit_loss >= 0 ? 'rgba(34, 197, 94, 0.5)' : 'rgba(239, 68, 68, 0.5)'
                        ),
                        type: 'bar',
                        borderWidth: 0,
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                            usePointStyle: true,
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            label: function(context) {
                                let label = context.dataset.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                label += formatCurrency(context.parsed.y);
                                return label;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {
                            color: 'rgba(156, 163, 175, 0.1)',
                        },
                        ticks: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                        }
                    },
                    y: {
                        grid: {
                            color: 'rgba(156, 163, 175, 0.1)',
                        },
                        ticks: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                            callback: function(value) {
                                return '$' + value.toFixed(2);
                            }
                        }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        });

    } catch (error) {
        console.error('Failed to load P&L chart:', error);
    }
}

/**
 * Load and display win/loss rate pie chart
 */
async function loadWinRateChart() {
    try {
        const response = await fetch(`${API_BASE}/performance/summary`);
        const data = await response.json();

        if (data.total_wins === 0 && data.total_losses === 0) {
            document.getElementById('winRateChart').innerHTML =
                '<p class="no-data">No completed trades yet</p>';
            return;
        }

        const ctx = document.getElementById('winRateChart').getContext('2d');

        // Destroy existing chart if it exists
        if (winRateChart) {
            winRateChart.destroy();
        }

        winRateChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Wins', 'Losses'],
                datasets: [{
                    data: [data.total_wins, data.total_losses],
                    backgroundColor: [
                        'rgba(34, 197, 94, 0.8)',
                        'rgba(239, 68, 68, 0.8)',
                    ],
                    borderColor: [
                        'rgb(34, 197, 94)',
                        'rgb(239, 68, 68)',
                    ],
                    borderWidth: 2,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${label}: ${value} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });

    } catch (error) {
        console.error('Failed to load win rate chart:', error);
    }
}

/**
 * Load and display algorithm performance comparison chart
 */
async function loadAlgorithmChart() {
    try {
        const response = await fetch(`${API_BASE}/performance/algorithms`);
        const data = await response.json();

        if (data.length === 0) {
            document.getElementById('algoChart').innerHTML =
                '<p class="no-data">No algorithm data available yet</p>';
            return;
        }

        const ctx = document.getElementById('algoChart').getContext('2d');

        // Destroy existing chart if it exists
        if (algoChart) {
            algoChart.destroy();
        }

        algoChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(d => d.name),
                datasets: [
                    {
                        label: 'Total Trades',
                        data: data.map(d => d.total_trades),
                        backgroundColor: 'rgba(99, 102, 241, 0.8)',
                        borderColor: 'rgb(99, 102, 241)',
                        borderWidth: 1,
                    },
                    {
                        label: 'Buy Orders',
                        data: data.map(d => d.buy_count),
                        backgroundColor: 'rgba(34, 197, 94, 0.8)',
                        borderColor: 'rgb(34, 197, 94)',
                        borderWidth: 1,
                    },
                    {
                        label: 'Sell Orders',
                        data: data.map(d => d.sell_count),
                        backgroundColor: 'rgba(239, 68, 68, 0.8)',
                        borderColor: 'rgb(239, 68, 68)',
                        borderWidth: 1,
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                            usePointStyle: true,
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                    }
                },
                scales: {
                    x: {
                        grid: {
                            color: 'rgba(156, 163, 175, 0.1)',
                        },
                        ticks: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                        }
                    },
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(156, 163, 175, 0.1)',
                        },
                        ticks: {
                            color: getComputedStyle(document.documentElement)
                                .getPropertyValue('--dark').trim() || '#111827',
                            precision: 0,
                        }
                    }
                }
            }
        });

    } catch (error) {
        console.error('Failed to load algorithm chart:', error);
    }
}

/**
 * Refresh all performance charts
 */
async function refreshPerformanceCharts() {
    const refreshBtn = document.querySelector('.refresh-performance');
    if (refreshBtn) {
        refreshBtn.classList.add('spinning');
    }

    await initPerformanceCharts();

    if (refreshBtn) {
        setTimeout(() => {
            refreshBtn.classList.remove('spinning');
        }, 500);
    }
}

/**
 * Format number as currency
 */
function formatCurrency(value) {
    if (value === null || value === undefined) return '$0.00';
    const formatted = Math.abs(value).toFixed(2);
    return value >= 0 ? `$${formatted}` : `-$${formatted}`;
}

/**
 * Format number as percentage
 */
function formatPercent(value) {
    if (value === null || value === undefined) return '0%';
    return `${(value * 100).toFixed(1)}%`;
}

// Initialize charts when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initPerformanceCharts);
} else {
    initPerformanceCharts();
}

// Auto-refresh every 30 seconds
setInterval(refreshPerformanceCharts, 30000);
