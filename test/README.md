# Babel Binance Test Suite

Comprehensive unit and integration tests for the babel_binance package.

## Test Coverage

This test suite includes **266 test cases** covering all aspects of the babel_binance library.

## Test Files

### 1. `exceptions_test.dart` (10.9 KB)
Tests for all custom exception types:
- `BinanceException` - Base exception
- `BinanceAuthenticationException` - Auth errors (401, 403)
- `BinanceRateLimitException` - Rate limit errors (429)
- `BinanceValidationException` - Invalid parameters (400)
- `BinanceNetworkException` - Network errors
- `BinanceServerException` - Server errors (500, 503)
- `BinanceInsufficientBalanceException` - Balance errors
- `BinanceTimeoutException` - Timeout errors

**Test Groups:**
- Basic exception creation
- Exception with status codes
- Exception with response bodies
- Exception hierarchy validation
- toString() formatting

### 2. `binance_config_test.dart` (9.6 KB)
Tests for configuration and client initialization:
- `BinanceConfig` default and custom configurations
- Timeout, retry, and rate limiting settings
- Client initialization with various credential combinations
- API module accessibility
- Multiple client instance independence

**Test Groups:**
- Default and custom configurations
- Client initialization variations
- API module accessibility
- Module lazy initialization

### 3. `spot_extended_test.dart` (10.3 KB)
Extended integration tests for Spot market APIs:
- Server time validation
- Exchange info structure
- Order book validation (bids/asks ordering)
- 24hr ticker data
- Rate limiting behavior
- Performance benchmarks
- Error handling for invalid symbols

**Test Groups:**
- Market data validation
- Order book consistency
- Concurrent requests
- Performance tests
- Error handling

### 4. `api_modules_test.dart` (11.7 KB)
Structural tests for all 25+ API modules:
- Spot, Futures (USD, Coin, Algo)
- Margin, Portfolio Margin
- Wallet, Sub-account
- Staking, Savings, Simple Earn, Auto Invest
- Loan, VIP Loan
- Convert, Simulated Convert, Copy Trading
- Fiat, C2C, Pay
- Mining, NFT, Gift Card, BLVT, Rebate

**Test Groups:**
- Module accessibility
- Module independence
- Method existence validation
- Configuration application
- Lazy initialization

### 5. `websockets_test.dart` (7.3 KB)
WebSocket functionality tests:
- WebSocket instance creation
- Stream connection and management
- Multiple concurrent streams
- Subscription handling
- Resource cleanup
- Error and completion handlers

**Test Groups:**
- Basic WebSocket operations
- Stream behavior
- Integration with UserDataStream
- Resource management
- Concurrency

### 6. `simulated_trading_extended_test.dart` (14.0 KB)
Comprehensive simulated trading tests:
- Market orders (BUY/SELL)
- Limit orders with various time-in-force
- Order status checking
- Multiple symbols and quantities
- Timing and delay simulation
- Performance benchmarks
- Edge cases (very small/large quantities)

**Test Groups:**
- Market orders
- Limit orders
- Order status
- Performance tests
- Edge cases
- Consistency validation

### 7. `simulated_convert_extended_test.dart` (17.4 KB)
Comprehensive simulated convert tests:
- Quote generation for various asset pairs
- Quote acceptance with success/failure scenarios
- Order status tracking
- Conversion history
- End-to-end conversion flows
- Performance benchmarks
- Edge cases

**Test Groups:**
- Get quote
- Accept quote
- Order status
- Conversion history
- End-to-end flows
- Performance tests
- Edge cases

### 8. `comprehensive_integration_test.dart` (14.6 KB)
Full integration tests combining multiple features:
- Library exports validation
- All API endpoints accessibility
- Real API integration (public endpoints)
- Simulated trading workflows
- Simulated convert workflows
- Mixed public and simulated APIs
- Error handling
- Performance and concurrency

**Test Groups:**
- Library entry points
- Real API integration
- Simulated feature integration
- Mixed API usage
- Error handling
- Concurrency tests
- Package metadata

### 9. `babel_binance_test.dart` (8.9 KB)
Original test suite (maintained):
- Basic Spot market tests
- Authenticated WebSocket tests
- Simulated trading tests
- Simulated convert tests

## Running Tests

### Run all tests:
```bash
dart test
```

### Run specific test file:
```bash
dart test test/exceptions_test.dart
```

### Run with coverage:
```bash
dart test --coverage=coverage
dart pub global activate coverage
format_coverage --lcov --in=coverage --out=coverage.lcov --report-on=lib
```

### Run with verbose output:
```bash
dart test --reporter=expanded
```

## Test Statistics

- **Total Test Files:** 9
- **Total Test Cases:** 266
- **Total Lines of Code:** 3,329
- **Code Coverage:** Comprehensive (all modules tested)

## Test Categories

### Unit Tests (150+ tests)
- Exception handling
- Configuration management
- Module structure validation
- WebSocket operations
- Data structure validation

### Integration Tests (80+ tests)
- Real API calls (public endpoints)
- Simulated trading flows
- Simulated convert flows
- End-to-end workflows
- Error scenarios

### Performance Tests (30+ tests)
- Response time benchmarks
- Concurrent request handling
- Rate limiting validation
- Delay simulation accuracy

## Test Environment

### Required Dependencies
- `dart` >=3.0.0 <4.0.0
- `test` ^1.25.2

### Optional Environment Variables
- `BINANCE_API_KEY` - For authenticated WebSocket tests (optional)

## Continuous Integration

Tests are designed to work in CI/CD environments:
- No real credentials required for most tests
- Public API tests use read-only endpoints
- Simulated tests require no authentication
- Authenticated tests are skipped if credentials not provided

## Test Best Practices

1. **Independence:** Each test is independent and can run in any order
2. **No Side Effects:** Tests don't modify external state
3. **Fast Execution:** Most tests complete in milliseconds
4. **Clear Descriptions:** Test names clearly describe what's being tested
5. **Comprehensive Coverage:** All public APIs and edge cases tested

## Adding New Tests

When adding new tests, follow this structure:

```dart
import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Feature Name Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Specific behavior description', () async {
      // Arrange
      final param = 'value';

      // Act
      final result = await binance.someModule.someMethod(param);

      // Assert
      expect(result, isNotNull);
      expect(result['key'], equals('expected'));
    });
  });
}
```

## Known Limitations

1. **Real Trading Tests:** Not included (requires real API credentials and funds)
2. **Authenticated Endpoints:** Most require real credentials (use simulated alternatives)
3. **WebSocket Live Data:** Tests focus on connection, not live data validation
4. **Rate Limiting:** Some tests may be rate-limited on slow connections

## Contributing

When contributing new tests:
1. Follow existing naming conventions
2. Group related tests together
3. Include both success and failure scenarios
4. Add performance tests for time-critical operations
5. Test edge cases (empty values, large values, invalid inputs)
6. Update this README with new test descriptions

## License

MIT License - Same as babel_binance package
