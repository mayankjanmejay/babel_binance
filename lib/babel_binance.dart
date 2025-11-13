/// A Dart library for interacting with the Binance API.
///
/// This library provides convenient access to the Binance REST API and WebSocket streams.
library babel_binance;

// Core
export 'src/babel_binance_base.dart';
export 'src/binance_base.dart';
export 'src/spot.dart';
export 'src/futures_usd.dart';
export 'src/margin.dart';
export 'src/testnet.dart';
export 'src/websockets.dart';
export 'src/simulated_convert.dart';

// Configuration
export 'src/config/binance_config.dart';

// Exceptions
export 'src/exceptions/binance_exception.dart';
export 'src/exceptions/api_exception.dart';
export 'src/exceptions/network_exception.dart';
export 'src/exceptions/validation_exception.dart';

// Logging
export 'src/logging/logger.dart';
export 'src/logging/log_level.dart';
export 'src/logging/console_logger.dart';

// Rate Limiting
export 'src/rate_limiting/rate_limiter.dart';
export 'src/rate_limiting/rate_limit_config.dart';

// WebSocket
export 'src/websocket/websocket_client.dart';
export 'src/websocket/websocket_config.dart';
export 'src/websocket/websocket_stream.dart';
export 'src/websocket/stream_types.dart';

// Additional API modules
export 'src/auto_invest.dart';
export 'src/blvt.dart';
export 'src/c2c.dart';
export 'src/convert.dart';
export 'src/copy_trading.dart';
export 'src/fiat.dart';
export 'src/futures_algo.dart';
export 'src/futures_coin.dart';
export 'src/gift_card.dart';
export 'src/loan.dart';
export 'src/mining.dart';
export 'src/nft.dart';
export 'src/pay.dart';
export 'src/portfolio_margin.dart';
export 'src/rebate.dart';
export 'src/savings.dart';
export 'src/simple_earn.dart';
export 'src/staking.dart';
export 'src/sub_account.dart';
export 'src/vip_loan.dart';
export 'src/wallet.dart';
