#!/bin/bash
# Script to apply all patches to BabelCoin repository
# Run this from the BabelCoin directory

set -e  # Exit on error

echo "=========================================="
echo "Applying babel_binance commits to BabelCoin"
echo "=========================================="
echo ""

# Check if we're in a git repo
if [ ! -d .git ]; then
    echo "❌ Error: Not in a git repository!"
    echo "Please run this script from the BabelCoin directory"
    exit 1
fi

# Check if patch files exist
PATCH_DIR="../babel_binance"
if [ ! -f "$PATCH_DIR/0001-Add-comprehensive-Flutter-example-app-with-subscript.patch" ]; then
    echo "❌ Error: Patch files not found in $PATCH_DIR"
    echo "Please ensure babel_binance directory is at the same level as BabelCoin"
    exit 1
fi

echo "✅ Found patch files in $PATCH_DIR"
echo ""

# Apply patches one by one
echo "📦 Applying patch 1/7: Flutter Example App..."
git am "$PATCH_DIR/0001-Add-comprehensive-Flutter-example-app-with-subscript.patch"

echo "📦 Applying patch 2/7: Appwrite Setup Wizard..."
git am "$PATCH_DIR/0002-Add-Appwrite-Setup-Wizard-with-comprehensive-databas.patch"

echo "📦 Applying patch 3/7: Feature Suite (Subscription, Privacy, Biometrics, AI, Media)..."
git am "$PATCH_DIR/0003-Add-comprehensive-feature-suite-Subscription-Privacy.patch"

echo "📦 Applying patch 4/7: Lock Screen Widget Framework..."
git am "$PATCH_DIR/0004-Add-lock-screen-widget-framework-and-comprehensive-d.patch"

echo "📦 Applying patch 5/7: Flutter App Cleanup..."
git am "$PATCH_DIR/0005-Remove-Flutter-app-example-files.patch"

echo "📦 Applying patch 6/7: Trading Bot & Enhanced Error Handling..."
git am "$PATCH_DIR/0006-Release-v0.7.0-Enhanced-error-handling-rate-limiting.patch"

echo "📦 Applying patch 7/7: Comprehensive Test Suite..."
git am "$PATCH_DIR/0007-Add-comprehensive-unit-test-suite-for-babel_binance.patch"

echo ""
echo "=========================================="
echo "✅ ALL PATCHES APPLIED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "What was added to BabelCoin:"
echo "  ✅ Flutter app with subscriptions & payments"
echo "  ✅ Appwrite setup wizard"
echo "  ✅ Subscription, Privacy, Biometrics features"
echo "  ✅ AI chat & Media recording"
echo "  ✅ Lock screen widgets"
echo "  ✅ Trading bot with enhanced Binance API"
echo "  ✅ 266 comprehensive unit tests"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git log -7 --oneline"
echo "  2. Push to BabelCoin: git push origin main"
echo "     (or create a branch: git checkout -b feature/trading-bot && git push origin feature/trading-bot)"
echo ""
