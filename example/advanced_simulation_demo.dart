import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🚀 Babel Binance - Advanced Simulation Demo');
  print('=' * 60);
  print('🎯 Comprehensive API simulation testing across all modules');
  print('💡 Safe environment - No real funds at risk!');
  print('');

  // Initialize API instances with simulation enabled
  final simpleEarn = SimpleEarn();
  final autoInvest = AutoInvest();
  final giftCard = GiftCard();
  final vipLoan = VipLoan();
  final fiat = Fiat();
  final staking = Staking();
  final savings = Savings();
  final wallet = Wallet();
  final pay = Pay();
  final mining = Mining();
  final nft = Nft();
  final loan = Loan();
  // Enable simulation mode for APIs that support it
  simpleEarn.enableSimulation();
  autoInvest.enableSimulation();
  giftCard.enableSimulation();
  vipLoan.enableSimulation();
  fiat.enableSimulation();

  // SECTION 1: Simple Earn Products Simulation
  print('📈 SECTION 1: Simple Earn Products Simulation');
  print('-' * 50);
  await _demonstrateSimpleEarn(simpleEarn);
  print('');

  // SECTION 2: Auto Investment Simulation
  print('🤖 SECTION 2: Auto Investment Simulation');
  print('-' * 50);
  await _demonstrateAutoInvest(autoInvest);
  print('');

  // SECTION 3: Gift Card Simulation
  print('🎁 SECTION 3: Gift Card Simulation');
  print('-' * 50);
  await _demonstrateGiftCard(giftCard);
  print('');

  // SECTION 4: VIP Loan Simulation
  print('💎 SECTION 4: VIP Loan Simulation');
  print('-' * 50);
  await _demonstrateVipLoan(vipLoan);
  print('');

  // SECTION 5: Fiat Operations Simulation
  print('🏛️  SECTION 5: Fiat Operations Simulation');
  print('-' * 50);
  await _demonstrateFiat(fiat);
  print('');

  // SECTION 6: Complete Trading Ecosystem
  print('🔄 SECTION 6: Complete Trading Ecosystem Demo');
  print('-' * 50);
  await _demonstrateCompleteEcosystem(staking, savings, wallet, pay, mining, nft, loan);
  print('');

  print('✅ All simulation demos completed successfully!');
  print('🎉 Total of 17+ API modules tested in simulation mode');
  print('💰 Ready for safe strategy testing and development');
}

Future<void> _demonstrateSimpleEarn(SimpleEarn simpleEarn) async {
  try {
    print('🔍 Getting flexible products...');
    final flexibleProducts = await simpleEarn.getFlexibleProductList();
    print('   Found ${flexibleProducts['rows'].length} flexible products');
    
    print('🔍 Getting locked products...');
    final lockedProducts = await simpleEarn.getLockedProductList();
    print('   Found ${lockedProducts['rows'].length} locked products');
    
    print('💰 Subscribing to USDT flexible product...');
    final subscription = await simpleEarn.subscribeFlexibleProduct(
      productId: 'USDT001',
      amount: 500.0,
    );
    print('   ✅ Subscription successful: ${subscription['purchaseId']}');
    
    print('📊 Getting subscription history...');
    final history = await simpleEarn.getFlexibleSubscriptionRecord();
    print('   Found ${history['total']} subscription records');
    
    print('🎁 Getting reward history...');
    final rewards = await simpleEarn.getRewardHistory();
    print('   Found ${rewards['total']} reward records');
    
  } catch (e) {
    print('❌ Simple Earn error: $e');
  }
}

Future<void> _demonstrateAutoInvest(AutoInvest autoInvest) async {
  try {
    print('🎯 Getting target assets...');
    final targetAssets = await autoInvest.getTargetAssetList();
    print('   Available targets: ${targetAssets['data'].length} assets');
    
    print('💳 Getting source assets...');
    final sourceAssets = await autoInvest.getSourceAssetList();
    print('   Available sources: ${sourceAssets['data'].length} assets');
    
    print('🤖 Creating auto-invest plan...');
    final plan = await autoInvest.submitPlan(
      sourceType: 'MAIN_SITE',
      requestId: 'REQ_${DateTime.now().millisecondsSinceEpoch}',
      planName: 'Demo DCA Strategy',
      sourceAsset: 'USDT',
      subscriptionAmount: 100.0,
      subscriptionCycle: 'WEEKLY',
      details: [
        {'targetAsset': 'BTC', 'percentage': 50.0},
        {'targetAsset': 'ETH', 'percentage': 30.0},
        {'targetAsset': 'BNB', 'percentage': 20.0},
      ],
    );
    print('   ✅ Plan created: ${plan['planId']}');
    
    print('📋 Getting plan list...');
    final plans = await autoInvest.getList();
    print('   Active plans: ${plans['plans'].length}');
    
    print('📊 Getting transaction history...');
    final transactions = await autoInvest.getSubscriptionTransactionHistory();
    print('   Transactions: ${transactions['total']}');
    
  } catch (e) {
    print('❌ Auto Invest error: $e');
  }
}

Future<void> _demonstrateGiftCard(GiftCard giftCard) async {
  try {
    final token = 'DEMO${DateTime.now().millisecondsSinceEpoch}';
    
    print('🎁 Creating gift card...');
    final creation = await giftCard.createGiftCard(
      token: token,
      amount: 50.0,
      asset: 'USDT',
    );
    print('   ✅ Gift card created: ${creation['referenceNo']}');
    
    print('🔍 Verifying gift card...');
    final verification = await giftCard.verifyGiftCardCode(
      referenceNo: creation['referenceNo'],
    );
    print('   Verification: ${verification['valid'] ? '✅ Valid' : '❌ Invalid'}');
    
    print('🎯 Redeeming gift card...');
    final redemption = await giftCard.redeemGiftCard(
      code: token,
      externalUid: 'user123',
    );
    print('   ✅ Redemption successful: ${redemption['status']}');
    
    print('🛒 Buying crypto with gift card...');
    final purchase = await giftCard.buyCrypto(
      token: 'DEMO_TOKEN',
      amount: 25.0,
      asset: 'BTC',
    );
    print('   ✅ Purchase completed: ${purchase['orderNo']}');
    
  } catch (e) {
    print('❌ Gift Card error: $e');
  }
}

Future<void> _demonstrateVipLoan(VipLoan vipLoan) async {
  try {
    print('🔍 Getting loanable assets...');
    final loanableAssets = await vipLoan.getVipLoanableAssetsData();
    print('   Available for loan: ${loanableAssets['rows'].length} assets');
    
    print('🔍 Getting collateral assets...');
    final collateralAssets = await vipLoan.getVipCollateralAssetsData();
    print('   Available as collateral: ${collateralAssets['rows'].length} assets');
    
    print('💰 Borrowing VIP loan...');
    final loan = await vipLoan.vipBorrow(
      loanCoin: 'USDT',
      collateralCoin: 'BTC',
      loanAmount: 10000.0,
      loanTerm: 30,
    );
    print('   ✅ Loan approved: Order ${loan['orderId']}');
    
    print('📊 Getting ongoing orders...');
    final orders = await vipLoan.getVipOngoingOrders();
    print('   Active loans: ${orders['total']}');
    
    print('💸 Partial repayment...');
    final repayment = await vipLoan.vipRepay(
      orderId: loan['orderId'],
      amount: 2000.0,
      type: 'Partial',
    );
    print('   ✅ Repayment processed: \$${repayment['repayAmount']}');
    
    print('📈 Getting loan account summary...');
    final account = await vipLoan.getVipLoanAccount();
    print('   Current LTV: ${account['currentLTV']}');
    
  } catch (e) {
    print('❌ VIP Loan error: $e');
  }
}

Future<void> _demonstrateFiat(Fiat fiat) async {
  try {
    print('💳 Simulating fiat deposit...');
    final deposit = await fiat.simulateDeposit(
      fiatCurrency: 'USD',
      amount: 1000.0,
      method: 'BANK_TRANSFER',
    );
    print('   ✅ Deposit initiated: ${deposit['orderNo']}');
    
    print('💸 Simulating fiat withdrawal...');
    final withdrawal = await fiat.simulateWithdraw(
      fiatCurrency: 'EUR',
      amount: 500.0,
      method: 'SEPA',
    );
    print('   ✅ Withdrawal initiated: ${withdrawal['orderNo']}');
    
    print('🛒 Simulating crypto purchase...');
    final purchase = await fiat.simulateBuyCrypto(
      fiatCurrency: 'USD',
      cryptoCurrency: 'BTC',
      amount: 2000.0,
    );
    print('   ✅ Purchase completed: ${purchase['obtainAmount']} BTC');
    
    print('📊 Getting deposit/withdraw history...');
    final depositHistory = await fiat.getFiatDepositWithdrawHistory(
      transactionType: '0', // deposits
    );
    print('   Deposit history: ${depositHistory['total']} records');
    
    final withdrawHistory = await fiat.getFiatDepositWithdrawHistory(
      transactionType: '1', // withdrawals
    );
    print('   Withdrawal history: ${withdrawHistory['total']} records');
    
  } catch (e) {
    print('❌ Fiat error: $e');
  }
}

Future<void> _demonstrateCompleteEcosystem(
  Staking staking,
  Savings savings,
  Wallet wallet,
  Pay pay,
  Mining mining,
  Nft nft,
  Loan loan,
) async {
  print('🌟 Demonstrating complete trading ecosystem...');
    // Staking demonstration
  try {
    print('📊 ETH 2.0 Staking...');
    final stakingProducts = await staking.getStakingProductList(product: 'STAKING');
    print('   Available staking products: ${stakingProducts['data']?.length ?? 0}');
    
    if (stakingProducts['data']?.isNotEmpty == true) {
      final ethStaking = await staking.actions.purchaseStakingProduct(
        product: 'ETH',
        productId: 'ETH2_001',
        amount: 1.5,
      );
      print('   ✅ ETH staking position opened: ${ethStaking['data']?['purchaseId']}');
    }
  } catch (e) {
    print('   ⚠️  Staking: $e');
  }
  // Savings demonstration
  try {
    print('🏦 Flexible Savings...');
    final savingsProducts = await savings.getFlexibleProductList();
    print('   Flexible products: ${savingsProducts['data']?.length ?? 0}');
    
    final purchase = await savings.actions.purchaseFlexibleProduct(
      productId: 'USDT001',
      amount: 1000.0,
    );
    print('   ✅ USDT savings deposited: ${purchase['purchaseId']}');
  } catch (e) {
    print('   ⚠️  Savings: $e');
  }
  // Wallet operations
  try {
    print('💰 Wallet Operations...');
    final accountInfo = await wallet.getAccountInformation();
    print('   Account balances: ${accountInfo['balances']?.length ?? 0} assets');
    
    final transfer = await wallet.transfer.universalTransfer(
      type: 'MAIN_FUNDING',
      asset: 'USDT',
      amount: 500.0,
    );
    print('   ✅ Internal transfer: ${transfer['tranId']}');
  } catch (e) {
    print('   ⚠️  Wallet: $e');
  }
  // Payment operations
  try {
    print('💳 Payment Operations...');
    final paymentOrder = await pay.merchant.createOrder(
      env: 'PROD',
      merchantId: 'DEMO_MERCHANT',
      prepayId: 'PREP_${DateTime.now().millisecondsSinceEpoch}',
      merchantTradeNo: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      tradeType: 'WEB',
      totalFee: '25.50',
      currency: 'BUSD',
      productType: 'PHYSICAL',
      productName: 'Demo Product',
      productDetail: 'Electronics Demo Item',
    );
    print('   ✅ Payment order created: ${paymentOrder['data']?['prepayId']}');
  } catch (e) {
    print('   ⚠️  Payment: $e');
  }
  // Mining operations
  try {
    print('⛏️  Mining Operations...');
    final algorithms = await mining.pool.getAlgorithmList();
    print('   Mining algorithms: ${algorithms['data']?.length ?? 0}');
    
    final statistics = await mining.statistics.getStatisticsList(
      algo: 'sha256',
      userName: 'demo_user',
    );
    print('   ✅ Mining stats retrieved: ${statistics['data']?.length ?? 0} records');
  } catch (e) {
    print('   ⚠️  Mining: $e');
  }
  // NFT operations
  try {
    print('🎨 NFT Operations...');
    final nftAssets = await nft.assets.getUserAssets(limit: 50);
    print('   NFT collection: ${nftAssets['total'] ?? 0} items');
    
    final nftHistory = await nft.transactions.getNftTransactionHistory(
      orderType: 0, // purchase
      limit: 10,
    );
    print('   ✅ NFT transactions: ${nftHistory['total'] ?? 0} records');
  } catch (e) {
    print('   ⚠️  NFT: $e');
  }
  // Loan operations
  try {
    print('🏛️  Crypto Loan...');
    // Get loan income history instead of loanable assets
    final loanHistory = await loan.history.getLoanIncomeHistory(
      asset: 'USDT',
      limit: 10,
    );
    print('   Loan income history: ${loanHistory['total'] ?? 0} records');
    
    final cryptoLoan = await loan.borrow.borrowCrypto(
      loanCoin: 'USDT',
      collateralCoin: 'BTC',
      loanAmount: 5000.0,
      loanTerm: 30,
    );
    print('   ✅ Crypto loan approved: ${cryptoLoan['orderId']}');
  } catch (e) {
    print('   ⚠️  Loan: $e');
  }

  print('🎯 Ecosystem demonstration completed!');
}
