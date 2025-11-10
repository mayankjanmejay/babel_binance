/// A Dart library for interacting with the Binance API.
///
/// This library provides convenient access to the Binance REST API and WebSocket streams.
///
/// Features:
/// - Complete coverage of all 25+ Binance API collections
/// - Automatic rate limiting to prevent API limit violations
/// - Retry logic for failed requests with exponential backoff
/// - Request timeout configuration
/// - Custom exception types for better error handling
/// - Simulated trading and conversion for testing
/// - WebSocket support for real-time data streams
///
/// Example usage:
/// ```dart
/// import 'package:babel_binance/babel_binance.dart';
///
/// void main() async {
///   final binance = Binance(
///     apiKey: 'YOUR_API_KEY',
///     apiSecret: 'YOUR_API_SECRET',
///   );
///
///   try {
///     // Get market data
///     final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
///     print('Bitcoin price: \$${ticker['lastPrice']}');
///
///     // Access wallet
///     final balance = await binance.wallet.getAllCoinsInfo();
///
///     // Futures trading
///     final futuresAccount = await binance.futuresUsd.getAccount();
///   } on BinanceRateLimitException catch (e) {
///     print('Rate limit hit: ${e.message}');
///   } on BinanceAuthenticationException catch (e) {
///     print('Auth error: ${e.message}');
///   } on BinanceException catch (e) {
///     print('API error: ${e.message}');
///   }
/// }
/// ```
library babel_binance;

// Core classes
export 'src/babel_binance_base.dart';
export 'src/binance_base.dart';
export 'src/exceptions.dart';

// API Collections
export 'src/auto_invest.dart';
export 'src/blvt.dart';
export 'src/c2c.dart';
export 'src/convert.dart';
export 'src/copy_trading.dart';
export 'src/fiat.dart';
export 'src/futures_algo.dart';
export 'src/futures_coin.dart';
export 'src/futures_usd.dart';
export 'src/gift_card.dart';
export 'src/loan.dart';
export 'src/margin.dart';
export 'src/mining.dart';
export 'src/nft.dart';
export 'src/pay.dart';
export 'src/portfolio_margin.dart';
export 'src/rebate.dart';
export 'src/savings.dart';
export 'src/simple_earn.dart';
export 'src/simulated_convert.dart';
export 'src/spot.dart';
export 'src/staking.dart';
export 'src/sub_account.dart';
export 'src/vip_loan.dart';
export 'src/wallet.dart';
export 'src/websockets.dart';
