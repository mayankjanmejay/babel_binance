## 0.6.2

- **deps**: Updated crypto dependency from ^3.0.3 to ^3.0.6
- **deps**: Updated http dependency from ^1.2.1 to ^1.4.0  
- **deps**: Updated web_socket_channel dependency from ^2.4.0 to ^3.0.3
- **improvement**: Enhanced compatibility with latest dependency versions
- **docs**: Updated documentation to reflect dependency version changes

## 0.6.1

- **fix**: Fixed compilation errors across multiple example files
- **fix**: Resolved digit separator issues in comprehensive_api_simulation_example.dart
- **fix**: Fixed type casting issues with null safety in dynamic map operations
- **fix**: Corrected return type mismatches in loan.dart and wallet.dart simulation methods
- **fix**: Replaced non-existent API method calls with available alternatives
- **improvement**: Rewrote comprehensive_api_simulation_example.dart to use only available APIs (spot, simulatedConvert, futuresUsd, margin)
- **improvement**: Enhanced example to demonstrate realistic trading scenarios with proper API usage
- **test**: All tests now pass successfully after compilation fixes
- **docs**: Updated examples to reflect actual API capabilities and structure

## 0.6.0

- **docs**: Complete README redesign with compelling introduction and enhanced user experience
- **docs**: Added professional badges and visual improvements to documentation
- **docs**: Enhanced quick start guide with simplified onboarding process
- **feat**: Version bump to reflect maturity and stability of the package
- **improvement**: Better positioning as the ultimate Dart Binance API wrapper
- **docs**: Emphasized comprehensive API coverage and developer-friendly features

## 0.5.3

- **feat**: Added comprehensive simulated trading functionality with realistic timing delays
- **feat**: Implemented simulated convert operations with market behavior simulation
- **feat**: Added timing analysis capabilities for measuring API response times
- **feat**: Realistic order processing simulation (50-500ms delays)
- **feat**: Realistic conversion processing simulation (500ms-3s delays)
- **feat**: Market price simulation with volatility and spread modeling
- **feat**: Order status progression simulation based on time and market conditions
- **test**: Added comprehensive test suite for simulation functionality
- **docs**: Updated README with detailed simulation documentation
- **example**: Enhanced example file with simulation demonstrations

## 0.5.2

- **feat**: Implement websockets and prepare for publishing.
- **refactor**: Restructured the `Spot` API, separating market data endpoints into a dedicated `Market` class.
- **refactor**: Optimized the core `BinanceBase` class for improved request handling.
- **test**: Added a comprehensive test suite for Spot and WebSocket functionalities.
- **test**: Removed hardcoded API keys from tests, now using environment variables.
- **docs**: Updated `README.md` with new API structure and websocket usage.
- **chore**: Added `LICENSE` file and updated `pubspec.yaml` for publishing.

## 0.5.1
- Exampples and optimizations

## 0.5.0
-   Initial release.
-   Complete implementation of all 25 Binance API collections.
-   Added Spot, Margin, Wallet, Websockets, Futures (USD & COIN), Sub-Account, Fiat, Mining, BLVT, Portfolio Margin, Staking, Savings, C2C, Pay, Convert, Rebate, NFT, Gift Card, Loan, Simple Earn, Auto-Invest, VIP-Loan, Futures Algo, and Copy Trading.