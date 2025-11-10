// ============================================================================
// DARK MODE / LIGHT MODE TOGGLE
// ============================================================================

// Initialize theme from localStorage or default to light
function initializeTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    setTheme(savedTheme);

    // Create theme toggle button
    createThemeToggleButton();
}

// Set theme
function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.body.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);

    // Update toggle button icon
    updateToggleButtonIcon(theme);
}

// Toggle between light and dark mode
function toggleTheme() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);

    // Add animation effect
    animateThemeChange();
}

// Create floating theme toggle button
function createThemeToggleButton() {
    // Check if button already exists
    if (document.getElementById('themeToggle')) return;

    const button = document.createElement('button');
    button.id = 'themeToggle';
    button.className = 'theme-toggle';
    button.setAttribute('aria-label', 'Toggle dark mode');
    button.setAttribute('title', 'Toggle dark/light mode');
    button.onclick = toggleTheme;

    document.body.appendChild(button);

    // Set initial icon
    const currentTheme = localStorage.getItem('theme') || 'light';
    updateToggleButtonIcon(currentTheme);
}

// Update toggle button icon
function updateToggleButtonIcon(theme) {
    const button = document.getElementById('themeToggle');
    if (!button) return;

    if (theme === 'dark') {
        button.innerHTML = '<i class="fas fa-sun"></i>';
        button.setAttribute('title', 'Switch to light mode');
    } else {
        button.innerHTML = '<i class="fas fa-moon"></i>';
        button.setAttribute('title', 'Switch to dark mode');
    }
}

// Animate theme change
function animateThemeChange() {
    const button = document.getElementById('themeToggle');
    if (button) {
        button.style.transform = 'rotate(360deg) scale(1.2)';
        setTimeout(() => {
            button.style.transform = '';
        }, 300);
    }
}

// Listen for system theme changes
function watchSystemTheme() {
    if (window.matchMedia) {
        const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');

        darkModeQuery.addListener((e) => {
            // Only auto-switch if user hasn't manually set a preference
            if (!localStorage.getItem('theme')) {
                setTheme(e.matches ? 'dark' : 'light');
            }
        });
    }
}

// Export for use in main app
window.initializeTheme = initializeTheme;
window.toggleTheme = toggleTheme;
window.setTheme = setTheme;

// Initialize on DOM load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeTheme);
} else {
    initializeTheme();
}

// Watch for system theme changes
watchSystemTheme();
