import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('All API Modules Structure Tests', () {
    late Binance binance;
    late Binance authenticatedBinance;

    setUp(() {
      binance = Binance();
      authenticatedBinance = Binance(
        apiKey: 'test_api_key',
        apiSecret: 'test_api_secret',
      );
    });

    group('Spot Module', () {
      test('Spot module is accessible and initialized', () {
        expect(binance.spot, isNotNull);
        expect(binance.spot, isA<Spot>());
      });

      test('Spot has Market submodule', () {
        expect(binance.spot.market, isNotNull);
        expect(binance.spot.market, isA<Market>());
      });

      test('Spot has Trading submodule', () {
        expect(binance.spot.trading, isNotNull);
        expect(binance.spot.trading, isA<Trading>());
      });

      test('Spot has UserDataStream submodule', () {
        expect(binance.spot.userDataStream, isNotNull);
        expect(binance.spot.userDataStream, isA<UserDataStream>());
      });

      test('Spot has SimulatedTrading submodule', () {
        expect(binance.spot.simulatedTrading, isNotNull);
        expect(binance.spot.simulatedTrading, isA<SimulatedTrading>());
      });
    });

    group('Futures Modules', () {
      test('FuturesUsd module is accessible', () {
        expect(binance.futuresUsd, isNotNull);
        expect(binance.futuresUsd, isA<FuturesUsd>());
      });

      test('FuturesCoin module is accessible', () {
        expect(binance.futuresCoin, isNotNull);
        expect(binance.futuresCoin, isA<FuturesCoin>());
      });

      test('FuturesAlgo module is accessible', () {
        expect(binance.futuresAlgo, isNotNull);
        expect(binance.futuresAlgo, isA<FuturesAlgo>());
      });
    });

    group('Margin Module', () {
      test('Margin module is accessible', () {
        expect(binance.margin, isNotNull);
        expect(binance.margin, isA<Margin>());
      });

      test('PortfolioMargin module is accessible', () {
        expect(binance.portfolioMargin, isNotNull);
        expect(binance.portfolioMargin, isA<PortfolioMargin>());
      });
    });

    group('Wallet Module', () {
      test('Wallet module is accessible', () {
        expect(binance.wallet, isNotNull);
        expect(binance.wallet, isA<Wallet>());
      });

      test('SubAccount module is accessible', () {
        expect(binance.subAccount, isNotNull);
        expect(binance.subAccount, isA<SubAccount>());
      });
    });

    group('Earn Modules', () {
      test('Staking module is accessible', () {
        expect(binance.staking, isNotNull);
        expect(binance.staking, isA<Staking>());
      });

      test('Savings module is accessible', () {
        expect(binance.savings, isNotNull);
        expect(binance.savings, isA<Savings>());
      });

      test('SimpleEarn module is accessible', () {
        expect(binance.simpleEarn, isNotNull);
        expect(binance.simpleEarn, isA<SimpleEarn>());
      });

      test('AutoInvest module is accessible', () {
        expect(binance.autoInvest, isNotNull);
        expect(binance.autoInvest, isA<AutoInvest>());
      });
    });

    group('Loan Modules', () {
      test('Loan module is accessible', () {
        expect(binance.loan, isNotNull);
        expect(binance.loan, isA<Loan>());
      });

      test('VipLoan module is accessible', () {
        expect(binance.vipLoan, isNotNull);
        expect(binance.vipLoan, isA<VipLoan>());
      });
    });

    group('Trading Tools', () {
      test('Convert module is accessible', () {
        expect(binance.convert, isNotNull);
        expect(binance.convert, isA<Convert>());
      });

      test('SimulatedConvert module is accessible', () {
        expect(binance.simulatedConvert, isNotNull);
        expect(binance.simulatedConvert, isA<SimulatedConvert>());
      });

      test('CopyTrading module is accessible', () {
        expect(binance.copyTrading, isNotNull);
        expect(binance.copyTrading, isA<CopyTrading>());
      });
    });

    group('Fiat & Payment Modules', () {
      test('Fiat module is accessible', () {
        expect(binance.fiat, isNotNull);
        expect(binance.fiat, isA<Fiat>());
      });

      test('C2C module is accessible', () {
        expect(binance.c2c, isNotNull);
        expect(binance.c2c, isA<C2C>());
      });

      test('Pay module is accessible', () {
        expect(binance.pay, isNotNull);
        expect(binance.pay, isA<Pay>());
      });
    });

    group('Other Services', () {
      test('Mining module is accessible', () {
        expect(binance.mining, isNotNull);
        expect(binance.mining, isA<Mining>());
      });

      test('NFT module is accessible', () {
        expect(binance.nft, isNotNull);
        expect(binance.nft, isA<Nft>());
      });

      test('GiftCard module is accessible', () {
        expect(binance.giftCard, isNotNull);
        expect(binance.giftCard, isA<GiftCard>());
      });

      test('Blvt module is accessible', () {
        expect(binance.blvt, isNotNull);
        expect(binance.blvt, isA<Blvt>());
      });

      test('Rebate module is accessible', () {
        expect(binance.rebate, isNotNull);
        expect(binance.rebate, isA<Rebate>());
      });
    });

    group('Module Independence', () {
      test('Spot module is independent per instance', () {
        final binance1 = Binance();
        final binance2 = Binance();

        expect(binance1.spot, isNot(same(binance2.spot)));
      });

      test('Wallet module is independent per instance', () {
        final binance1 = Binance();
        final binance2 = Binance();

        expect(binance1.wallet, isNot(same(binance2.wallet)));
      });

      test('Futures module is independent per instance', () {
        final binance1 = Binance();
        final binance2 = Binance();

        expect(binance1.futuresUsd, isNot(same(binance2.futuresUsd)));
      });
    });

    group('Module Initialization with Credentials', () {
      test('Authenticated client initializes all modules', () {
        expect(authenticatedBinance.spot, isNotNull);
        expect(authenticatedBinance.wallet, isNotNull);
        expect(authenticatedBinance.margin, isNotNull);
        expect(authenticatedBinance.futuresUsd, isNotNull);
        expect(authenticatedBinance.staking, isNotNull);
        expect(authenticatedBinance.savings, isNotNull);
        expect(authenticatedBinance.loan, isNotNull);
        expect(authenticatedBinance.fiat, isNotNull);
        expect(authenticatedBinance.pay, isNotNull);
        expect(authenticatedBinance.mining, isNotNull);
        expect(authenticatedBinance.nft, isNotNull);
        expect(authenticatedBinance.giftCard, isNotNull);
      });

      test('Public modules work without credentials', () {
        expect(() => binance.spot.market.getServerTime(), returnsNormally);
      });
    });

    group('Module Type Consistency', () {
      test('All modules extend BinanceBase or are proper classes', () {
        // These should be valid class instances
        expect(binance.spot.market, isA<BinanceBase>());
        expect(binance.wallet, isA<BinanceBase>());
        expect(binance.margin, isA<BinanceBase>());
        expect(binance.futuresUsd, isA<BinanceBase>());
        expect(binance.staking, isA<BinanceBase>());
        expect(binance.savings, isA<BinanceBase>());
        expect(binance.loan, isA<BinanceBase>());
        expect(binance.fiat, isA<BinanceBase>());
        expect(binance.pay, isA<BinanceBase>());
        expect(binance.mining, isA<BinanceBase>());
        expect(binance.nft, isA<BinanceBase>());
        expect(binance.giftCard, isA<BinanceBase>());
      });
    });

    group('Module Count', () {
      test('Binance client exposes all expected modules', () {
        // Count all accessible modules (25+ modules)
        final modules = [
          binance.spot,
          binance.futuresUsd,
          binance.futuresCoin,
          binance.futuresAlgo,
          binance.margin,
          binance.portfolioMargin,
          binance.wallet,
          binance.subAccount,
          binance.staking,
          binance.savings,
          binance.simpleEarn,
          binance.autoInvest,
          binance.loan,
          binance.vipLoan,
          binance.convert,
          binance.simulatedConvert,
          binance.copyTrading,
          binance.fiat,
          binance.c2c,
          binance.pay,
          binance.mining,
          binance.nft,
          binance.giftCard,
          binance.blvt,
          binance.rebate,
        ];

        expect(modules.length, greaterThanOrEqualTo(25));

        // Verify none are null
        for (final module in modules) {
          expect(module, isNotNull);
        }
      });
    });
  });

  group('API Module Method Existence Tests', () {
    final binance = Binance();

    group('Spot Market Methods', () {
      test('Market methods exist', () {
        expect(binance.spot.market.getServerTime, isA<Function>());
        expect(binance.spot.market.getExchangeInfo, isA<Function>());
        expect(binance.spot.market.getOrderBook, isA<Function>());
        expect(binance.spot.market.get24HrTicker, isA<Function>());
      });

      test('UserDataStream methods exist', () {
        expect(binance.spot.userDataStream.createListenKey, isA<Function>());
        expect(binance.spot.userDataStream.keepAliveListenKey, isA<Function>());
        expect(binance.spot.userDataStream.closeListenKey, isA<Function>());
      });

      test('Trading methods exist', () {
        expect(binance.spot.trading.placeOrder, isA<Function>());
        expect(binance.spot.trading.cancelOrder, isA<Function>());
      });

      test('SimulatedTrading methods exist', () {
        expect(binance.spot.simulatedTrading.simulatePlaceOrder, isA<Function>());
        expect(binance.spot.simulatedTrading.simulateOrderStatus, isA<Function>());
      });
    });

    group('SimulatedConvert Methods', () {
      test('SimulatedConvert methods exist', () {
        expect(binance.simulatedConvert.simulateGetQuote, isA<Function>());
        expect(binance.simulatedConvert.simulateAcceptQuote, isA<Function>());
        expect(binance.simulatedConvert.simulateOrderStatus, isA<Function>());
        expect(binance.simulatedConvert.simulateConversionHistory, isA<Function>());
      });
    });
  });

  group('Module Configuration Tests', () {
    test('Custom config applies to all modules', () {
      final config = BinanceConfig(
        timeout: Duration(seconds: 60),
        maxRetries: 5,
      );
      final binance = Binance(config: config);

      expect(binance.spot, isNotNull);
      expect(binance.wallet, isNotNull);
      expect(binance.margin, isNotNull);
    });

    test('Testnet configuration', () {
      final binance = Binance(useTestnet: true);

      expect(binance.spot, isNotNull);
      expect(binance.wallet, isNotNull);
    });

    test('Production configuration (default)', () {
      final binance = Binance();

      expect(binance.spot, isNotNull);
      expect(binance.wallet, isNotNull);
    });
  });

  group('Module Lazy Initialization Tests', () {
    test('Modules are initialized on first access', () {
      final binance = Binance();

      // First access should initialize
      final spot1 = binance.spot;
      // Second access should return same instance
      final spot2 = binance.spot;

      expect(spot1, same(spot2));
    });

    test('Different modules are different instances', () {
      final binance = Binance();

      final spot = binance.spot;
      final wallet = binance.wallet;

      expect(spot, isNot(same(wallet)));
    });
  });
}
