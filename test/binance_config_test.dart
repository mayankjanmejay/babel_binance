import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceConfig Tests', () {
    test('Default Configuration', () {
      final config = BinanceConfig();

      expect(config.timeout, equals(Duration(seconds: 30)));
      expect(config.maxRetries, equals(3));
      expect(config.retryDelay, equals(Duration(seconds: 1)));
      expect(config.enableRateLimiting, isTrue);
      expect(config.maxRequestsPerSecond, equals(10));
    });

    test('Custom Timeout', () {
      final config = BinanceConfig(
        timeout: Duration(seconds: 60),
      );

      expect(config.timeout, equals(Duration(seconds: 60)));
      expect(config.maxRetries, equals(3)); // Default
      expect(config.retryDelay, equals(Duration(seconds: 1))); // Default
    });

    test('Custom Max Retries', () {
      final config = BinanceConfig(
        maxRetries: 5,
      );

      expect(config.maxRetries, equals(5));
      expect(config.timeout, equals(Duration(seconds: 30))); // Default
    });

    test('Custom Retry Delay', () {
      final config = BinanceConfig(
        retryDelay: Duration(seconds: 2),
      );

      expect(config.retryDelay, equals(Duration(seconds: 2)));
      expect(config.maxRetries, equals(3)); // Default
    });

    test('Disable Rate Limiting', () {
      final config = BinanceConfig(
        enableRateLimiting: false,
      );

      expect(config.enableRateLimiting, isFalse);
      expect(config.maxRequestsPerSecond, equals(10)); // Default
    });

    test('Custom Rate Limit', () {
      final config = BinanceConfig(
        maxRequestsPerSecond: 20,
      );

      expect(config.maxRequestsPerSecond, equals(20));
      expect(config.enableRateLimiting, isTrue); // Default
    });

    test('Fully Custom Configuration', () {
      final config = BinanceConfig(
        timeout: Duration(minutes: 2),
        maxRetries: 10,
        retryDelay: Duration(milliseconds: 500),
        enableRateLimiting: false,
        maxRequestsPerSecond: 50,
      );

      expect(config.timeout, equals(Duration(minutes: 2)));
      expect(config.maxRetries, equals(10));
      expect(config.retryDelay, equals(Duration(milliseconds: 500)));
      expect(config.enableRateLimiting, isFalse);
      expect(config.maxRequestsPerSecond, equals(50));
    });

    test('Aggressive Configuration', () {
      final config = BinanceConfig(
        timeout: Duration(seconds: 5),
        maxRetries: 1,
        retryDelay: Duration(milliseconds: 100),
        maxRequestsPerSecond: 100,
      );

      expect(config.timeout.inSeconds, equals(5));
      expect(config.maxRetries, equals(1));
      expect(config.retryDelay.inMilliseconds, equals(100));
      expect(config.maxRequestsPerSecond, equals(100));
    });

    test('Conservative Configuration', () {
      final config = BinanceConfig(
        timeout: Duration(minutes: 5),
        maxRetries: 10,
        retryDelay: Duration(seconds: 5),
        maxRequestsPerSecond: 1,
      );

      expect(config.timeout.inMinutes, equals(5));
      expect(config.maxRetries, equals(10));
      expect(config.retryDelay.inSeconds, equals(5));
      expect(config.maxRequestsPerSecond, equals(1));
    });

    test('Zero Retries Configuration', () {
      final config = BinanceConfig(
        maxRetries: 0,
      );

      // Should allow 0 retries (fail immediately)
      expect(config.maxRetries, equals(0));
    });

    test('Very Short Timeout', () {
      final config = BinanceConfig(
        timeout: Duration(milliseconds: 500),
      );

      expect(config.timeout.inMilliseconds, equals(500));
    });

    test('Const Configuration', () {
      const config = BinanceConfig();

      expect(config.timeout, equals(Duration(seconds: 30)));
      expect(config.maxRetries, equals(3));
      expect(config.retryDelay, equals(Duration(seconds: 1)));
      expect(config.enableRateLimiting, isTrue);
      expect(config.maxRequestsPerSecond, equals(10));
    });

    test('Multiple Instances with Different Configs', () {
      final config1 = BinanceConfig(timeout: Duration(seconds: 10));
      final config2 = BinanceConfig(timeout: Duration(seconds: 20));

      expect(config1.timeout.inSeconds, equals(10));
      expect(config2.timeout.inSeconds, equals(20));
      expect(config1.timeout, isNot(equals(config2.timeout)));
    });

    test('Rate Limiting Edge Cases', () {
      final config1 = BinanceConfig(maxRequestsPerSecond: 1);
      final config2 = BinanceConfig(maxRequestsPerSecond: 1000);

      expect(config1.maxRequestsPerSecond, equals(1));
      expect(config2.maxRequestsPerSecond, equals(1000));
    });
  });

  group('Binance Client Initialization Tests', () {
    test('Initialize without API credentials', () {
      final binance = Binance();

      expect(binance, isNotNull);
      expect(binance.spot, isNotNull);
      expect(binance.spot.market, isNotNull);
    });

    test('Initialize with API key only', () {
      final binance = Binance(apiKey: 'test_api_key');

      expect(binance, isNotNull);
      expect(binance.spot, isNotNull);
    });

    test('Initialize with API key and secret', () {
      final binance = Binance(
        apiKey: 'test_api_key',
        apiSecret: 'test_api_secret',
      );

      expect(binance, isNotNull);
      expect(binance.spot, isNotNull);
    });

    test('Initialize with custom config', () {
      final config = BinanceConfig(
        timeout: Duration(seconds: 60),
        maxRetries: 5,
      );
      final binance = Binance(config: config);

      expect(binance, isNotNull);
      expect(binance.spot, isNotNull);
    });

    test('Initialize with testnet', () {
      final binance = Binance(useTestnet: true);

      expect(binance, isNotNull);
      expect(binance.spot, isNotNull);
    });

    test('Access all API modules', () {
      final binance = Binance();

      // Core trading APIs
      expect(binance.spot, isNotNull);
      expect(binance.futuresUsd, isNotNull);
      expect(binance.futuresCoin, isNotNull);
      expect(binance.margin, isNotNull);

      // Wallet
      expect(binance.wallet, isNotNull);

      // Earn products
      expect(binance.staking, isNotNull);
      expect(binance.savings, isNotNull);
      expect(binance.simpleEarn, isNotNull);
      expect(binance.autoInvest, isNotNull);

      // Loans
      expect(binance.loan, isNotNull);
      expect(binance.vipLoan, isNotNull);

      // Fiat & Payment
      expect(binance.fiat, isNotNull);
      expect(binance.pay, isNotNull);

      // Other services
      expect(binance.mining, isNotNull);
      expect(binance.nft, isNotNull);
      expect(binance.giftCard, isNotNull);
    });

    test('Multiple client instances are independent', () {
      final binance1 = Binance(apiKey: 'key1');
      final binance2 = Binance(apiKey: 'key2');

      expect(binance1, isNot(same(binance2)));
      expect(binance1.spot, isNot(same(binance2.spot)));
    });
  });

  group('API Module Accessibility Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Spot Market is accessible', () {
      expect(() => binance.spot.market, returnsNormally);
      expect(binance.spot.market, isNotNull);
    });

    test('Spot Trading is accessible', () {
      expect(() => binance.spot.trading, returnsNormally);
      expect(binance.spot.trading, isNotNull);
    });

    test('Futures USD is accessible', () {
      expect(() => binance.futuresUsd, returnsNormally);
      expect(binance.futuresUsd, isNotNull);
    });

    test('Margin is accessible', () {
      expect(() => binance.margin, returnsNormally);
      expect(binance.margin, isNotNull);
    });

    test('Wallet is accessible', () {
      expect(() => binance.wallet, returnsNormally);
      expect(binance.wallet, isNotNull);
    });

    test('Staking is accessible', () {
      expect(() => binance.staking, returnsNormally);
      expect(binance.staking, isNotNull);
    });

    test('Savings is accessible', () {
      expect(() => binance.savings, returnsNormally);
      expect(binance.savings, isNotNull);
    });

    test('Simple Earn is accessible', () {
      expect(() => binance.simpleEarn, returnsNormally);
      expect(binance.simpleEarn, isNotNull);
    });

    test('Auto Invest is accessible', () {
      expect(() => binance.autoInvest, returnsNormally);
      expect(binance.autoInvest, isNotNull);
    });

    test('Loan is accessible', () {
      expect(() => binance.loan, returnsNormally);
      expect(binance.loan, isNotNull);
    });

    test('VIP Loan is accessible', () {
      expect(() => binance.vipLoan, returnsNormally);
      expect(binance.vipLoan, isNotNull);
    });

    test('Fiat is accessible', () {
      expect(() => binance.fiat, returnsNormally);
      expect(binance.fiat, isNotNull);
    });

    test('Pay is accessible', () {
      expect(() => binance.pay, returnsNormally);
      expect(binance.pay, isNotNull);
    });

    test('Mining is accessible', () {
      expect(() => binance.mining, returnsNormally);
      expect(binance.mining, isNotNull);
    });

    test('NFT is accessible', () {
      expect(() => binance.nft, returnsNormally);
      expect(binance.nft, isNotNull);
    });

    test('Gift Card is accessible', () {
      expect(() => binance.giftCard, returnsNormally);
      expect(binance.giftCard, isNotNull);
    });

    test('Simulated Convert is accessible', () {
      expect(() => binance.simulatedConvert, returnsNormally);
      expect(binance.simulatedConvert, isNotNull);
    });
  });
}
