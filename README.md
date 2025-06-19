# Binance Dart

A comprehensive, unofficial Dart wrapper for the public Binance API. It covers all 25 API collections, including Spot, Margin, Futures, Wallet, and more.

## Features

-   **Complete Coverage**: Implements all 25 official Binance API collections.
-   **Type-Safe**: Clean, readable, and type-safe Dart code.
-   **Authenticated & Unauthenticated**: Access both public and private endpoints.
-   **Well-Structured**: Each API collection is organized into its own class for clarity.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  babel_binance: ^0.5.1
```

## Usage

Import the main library and instantiate the API class for the collection you want to use.

```dart
import 'package:babel_binance/babel_binance.dart';

void main() async {
  // Example: Get server time from the Spot API
  final spot = Spot();
  final serverTime = await spot.getServerTime();
  print('Server Time: ${serverTime['serverTime']}');

  // Example: Using an authenticated endpoint (replace with your keys)
  final apiKey = 'YOUR_API_KEY';
  final apiSecret = 'YOUR_API_SECRET';

  final wallet = Wallet(apiKey: apiKey, apiSecret: apiSecret);
  final accountInfo = await wallet.getAccountInformation();
  print('Account Info: $accountInfo');
}
```

## API Collections Included

1.  Spot
2.  Margin
3.  Wallet
4.  Websockets
5.  Futures Coin
6.  Futures USD
7.  Sub-Account
8.  Fiat
9.  Mining
10. BLVT
11. Portfolio Margin
12. Staking
13. Savings
14. C2C
15. Pay
16. Convert
17. Rebate
18. NFT
19. Gift Card
20. Loan
21. Simple Earn
22. Auto-Invest
23. VIP-Loan
24. Futures Algo
25. Copy Trading