import './spot.dart';
import './simulated_convert.dart';
import './futures_usd.dart';
import './futures_coin.dart';
import './futures_algo.dart';
import './margin.dart';
import './wallet.dart';
import './sub_account.dart';
import './fiat.dart';
import './c2c.dart';
import './vip_loan.dart';
import './mining.dart';
import './blvt.dart';
import './portfolio_margin.dart';
import './staking.dart';
import './savings.dart';
import './simple_earn.dart';
import './pay.dart';
import './convert.dart';
import './rebate.dart';
import './nft.dart';
import './gift_card.dart';
import './loan.dart';
import './auto_invest.dart';
import './copy_trading.dart';

/// Main Binance API client providing access to all Binance API endpoints.
///
/// This is the primary entry point for interacting with the Binance API.
/// It provides convenient access to all 25+ API collections.
///
/// Example usage:
/// ```dart
/// final binance = Binance(
///   apiKey: 'YOUR_API_KEY',
///   apiSecret: 'YOUR_API_SECRET',
/// );
///
/// // Access spot market data
/// final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
///
/// // Access futures trading
/// final futuresBalance = await binance.futuresUsd.getBalance();
///
/// // Access wallet operations
/// final walletStatus = await binance.wallet.getSystemStatus();
/// ```
class Binance {
  // Core Trading APIs
  final Spot spot;
  final FuturesUsd futuresUsd;
  final FuturesCoin futuresCoin;
  final FuturesAlgo futuresAlgo;
  final Margin margin;
  final PortfolioMargin portfolioMargin;

  // Wallet & Account
  final Wallet wallet;
  final SubAccount subAccount;

  // Earn Products
  final Staking staking;
  final Savings savings;
  final SimpleEarn simpleEarn;
  final AutoInvest autoInvest;

  // Lending & Loans
  final Loan loan;
  final VipLoan vipLoan;

  // Trading Tools
  final Convert convert;
  final SimulatedConvert simulatedConvert;
  final CopyTrading copyTrading;

  // Fiat & Payment
  final Fiat fiat;
  final C2C c2c;
  final Pay pay;

  // Other Services
  final Mining mining;
  final BLVT blvt;
  final NFT nft;
  final GiftCard giftCard;
  final Rebate rebate;

  Binance({String? apiKey, String? apiSecret})
      : spot = Spot(apiKey: apiKey, apiSecret: apiSecret),
        futuresUsd = FuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
        futuresCoin = FuturesCoin(apiKey: apiKey, apiSecret: apiSecret),
        futuresAlgo = FuturesAlgo(apiKey: apiKey, apiSecret: apiSecret),
        margin = Margin(apiKey: apiKey, apiSecret: apiSecret),
        portfolioMargin = PortfolioMargin(apiKey: apiKey, apiSecret: apiSecret),
        wallet = Wallet(apiKey: apiKey, apiSecret: apiSecret),
        subAccount = SubAccount(apiKey: apiKey, apiSecret: apiSecret),
        staking = Staking(apiKey: apiKey, apiSecret: apiSecret),
        savings = Savings(apiKey: apiKey, apiSecret: apiSecret),
        simpleEarn = SimpleEarn(apiKey: apiKey, apiSecret: apiSecret),
        autoInvest = AutoInvest(apiKey: apiKey, apiSecret: apiSecret),
        loan = Loan(apiKey: apiKey, apiSecret: apiSecret),
        vipLoan = VipLoan(apiKey: apiKey, apiSecret: apiSecret),
        convert = Convert(apiKey: apiKey, apiSecret: apiSecret),
        simulatedConvert = SimulatedConvert(apiKey: apiKey, apiSecret: apiSecret),
        copyTrading = CopyTrading(apiKey: apiKey, apiSecret: apiSecret),
        fiat = Fiat(apiKey: apiKey, apiSecret: apiSecret),
        c2c = C2C(apiKey: apiKey, apiSecret: apiSecret),
        pay = Pay(apiKey: apiKey, apiSecret: apiSecret),
        mining = Mining(apiKey: apiKey, apiSecret: apiSecret),
        blvt = BLVT(apiKey: apiKey, apiSecret: apiSecret),
        nft = NFT(apiKey: apiKey, apiSecret: apiSecret),
        giftCard = GiftCard(apiKey: apiKey, apiSecret: apiSecret),
        rebate = Rebate(apiKey: apiKey, apiSecret: apiSecret);
}

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}
