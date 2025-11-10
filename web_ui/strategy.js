// Strategy Composer Management Module

const API_BASE = 'http://localhost:3000/api';

let currentConfig = null;

/**
 * Initialize strategy management
 */
async function initStrategyManagement() {
    try {
        await loadStrategyConfig();
        setupEventListeners();
        console.log('✅ Strategy management loaded');
    } catch (error) {
        console.error('Failed to load strategy management:', error);
    }
}

/**
 * Load current strategy configuration
 */
async function loadStrategyConfig() {
    try {
        const response = await fetch(`${API_BASE}/strategy/config`);
        if (!response.ok) {
            // Config endpoint doesn't exist yet, use default
            currentConfig = getDefaultConfig();
        } else {
            currentConfig = await response.json();
        }

        renderStrategyConfig(currentConfig);
    } catch (error) {
        console.error('Failed to load strategy config:', error);
        currentConfig = getDefaultConfig();
        renderStrategyConfig(currentConfig);
    }
}

/**
 * Get default configuration
 */
function getDefaultConfig() {
    return {
        enabled: true,
        mode: 'voting',
        requiredVotes: 2,
        algorithms: [
            { name: 'SMA Crossover', enabled: true, weight: 0.4 },
            { name: 'RSI Strategy', enabled: true, weight: 0.35 },
            { name: 'Grid Trading', enabled: true, weight: 0.25 }
        ]
    };
}

/**
 * Render strategy configuration UI
 */
function renderStrategyConfig(config) {
    // Update mode selector
    document.getElementById('strategyMode').value = config.mode;

    // Update enabled toggle
    document.getElementById('strategyEnabled').checked = config.enabled;

    // Update required votes (for voting mode)
    document.getElementById('requiredVotes').value = config.requiredVotes || 2;

    // Show/hide mode-specific controls
    updateModeControls(config.mode);

    // Render algorithm list
    renderAlgorithmList(config.algorithms);
}

/**
 * Update mode-specific controls visibility
 */
function updateModeControls(mode) {
    const votingControls = document.getElementById('votingControls');
    const weightedControls = document.getElementById('weightedControls');
    const unanimousInfo = document.getElementById('unanimousInfo');

    // Hide all first
    votingControls.style.display = 'none';
    weightedControls.style.display = 'none';
    unanimousInfo.style.display = 'none';

    // Show relevant controls
    switch (mode) {
        case 'voting':
            votingControls.style.display = 'block';
            break;
        case 'weighted':
            weightedControls.style.display = 'block';
            break;
        case 'unanimous':
            unanimousInfo.style.display = 'block';
            break;
    }
}

/**
 * Render algorithm list with weights
 */
function renderAlgorithmList(algorithms) {
    const container = document.getElementById('algorithmList');

    let html = '';
    algorithms.forEach((algo, index) => {
        html += `
            <div class="algorithm-item">
                <div class="algorithm-info">
                    <label class="checkbox-label">
                        <input
                            type="checkbox"
                            id="algo_${index}"
                            ${algo.enabled ? 'checked' : ''}
                            onchange="toggleAlgorithm(${index})"
                        >
                        <strong>${algo.name}</strong>
                    </label>
                    <span class="algorithm-status ${algo.enabled ? 'active' : 'inactive'}">
                        ${algo.enabled ? 'Active' : 'Inactive'}
                    </span>
                </div>
                <div class="algorithm-weight">
                    <label>Weight:</label>
                    <input
                        type="range"
                        min="0"
                        max="100"
                        value="${(algo.weight * 100).toFixed(0)}"
                        id="weight_${index}"
                        oninput="updateWeight(${index}, this.value)"
                        ${currentConfig.mode !== 'weighted' ? 'disabled' : ''}
                    >
                    <span id="weight_value_${index}">${(algo.weight * 100).toFixed(0)}%</span>
                </div>
            </div>
        `;
    });

    container.innerHTML = html;
}

/**
 * Toggle algorithm enabled/disabled
 */
function toggleAlgorithm(index) {
    currentConfig.algorithms[index].enabled = document.getElementById(`algo_${index}`).checked;
    renderAlgorithmList(currentConfig.algorithms);
}

/**
 * Update algorithm weight
 */
function updateWeight(index, value) {
    const weight = parseFloat(value) / 100;
    currentConfig.algorithms[index].weight = weight;
    document.getElementById(`weight_value_${index}`).textContent = `${value}%`;

    // Auto-normalize weights to sum to 100%
    if (currentConfig.mode === 'weighted') {
        normalizeWeights();
    }
}

/**
 * Normalize weights to sum to 1.0
 */
function normalizeWeights() {
    const total = currentConfig.algorithms.reduce((sum, algo) => sum + algo.weight, 0);

    if (Math.abs(total - 1.0) > 0.01) {
        // Display warning if weights don't sum to 100%
        document.getElementById('weightWarning').style.display = 'block';
        document.getElementById('weightWarning').textContent =
            `⚠️ Weights sum to ${(total * 100).toFixed(0)}%. They should sum to 100%.`;
    } else {
        document.getElementById('weightWarning').style.display = 'none';
    }
}

/**
 * Auto-balance weights evenly
 */
function autoBalanceWeights() {
    const enabledAlgos = currentConfig.algorithms.filter(a => a.enabled);
    const equalWeight = 1.0 / enabledAlgos.length;

    currentConfig.algorithms.forEach(algo => {
        if (algo.enabled) {
            algo.weight = equalWeight;
        } else {
            algo.weight = 0;
        }
    });

    renderAlgorithmList(currentConfig.algorithms);
    normalizeWeights();
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Strategy mode change
    document.getElementById('strategyMode').addEventListener('change', (e) => {
        currentConfig.mode = e.target.value;
        updateModeControls(e.target.value);
        renderAlgorithmList(currentConfig.algorithms);
    });

    // Enabled toggle
    document.getElementById('strategyEnabled').addEventListener('change', (e) => {
        currentConfig.enabled = e.target.checked;
        updateStrategyStatus();
    });

    // Required votes change
    document.getElementById('requiredVotes').addEventListener('change', (e) => {
        currentConfig.requiredVotes = parseInt(e.target.value);
    });
}

/**
 * Update strategy status display
 */
function updateStrategyStatus() {
    const statusEl = document.getElementById('strategyStatus');
    if (currentConfig.enabled) {
        statusEl.className = 'status-badge status-active';
        statusEl.textContent = 'Multi-Strategy Active';
    } else {
        statusEl.className = 'status-badge status-inactive';
        statusEl.textContent = 'Independent Algorithms';
    }
}

/**
 * Save strategy configuration
 */
async function saveStrategyConfig() {
    try {
        // Validate configuration
        if (currentConfig.mode === 'weighted') {
            const total = currentConfig.algorithms.reduce((sum, algo) => sum + algo.weight, 0);
            if (Math.abs(total - 1.0) > 0.01) {
                showError('Weights must sum to 100% in weighted mode');
                return;
            }
        }

        if (currentConfig.mode === 'voting') {
            const enabledCount = currentConfig.algorithms.filter(a => a.enabled).length;
            if (currentConfig.requiredVotes > enabledCount) {
                showError(`Required votes (${currentConfig.requiredVotes}) cannot exceed enabled algorithms (${enabledCount})`);
                return;
            }
        }

        // Save to backend
        const response = await fetch(`${API_BASE}/strategy/config`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(currentConfig),
        });

        if (response.ok) {
            showSuccess('Strategy configuration saved! Restart bot to apply changes.');
        } else {
            showError('Failed to save configuration');
        }
    } catch (error) {
        console.error('Failed to save strategy config:', error);
        showError('Failed to save configuration: ' + error.message);
    }
}

/**
 * Show success message
 */
function showSuccess(message) {
    const toast = document.createElement('div');
    toast.className = 'toast toast-success';
    toast.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('show');
    }, 100);

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
}

/**
 * Show error message
 */
function showError(message) {
    const toast = document.createElement('div');
    toast.className = 'toast toast-error';
    toast.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('show');
    }, 100);

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 4000);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initStrategyManagement);
} else {
    initStrategyManagement();
}
