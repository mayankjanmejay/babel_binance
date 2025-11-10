# 🧪 Testing Guide

Complete guide to running and writing tests for the Crypto Trading Platform.

---

## 📋 Test Coverage

### Bot Service Tests (Dart)
- **Technical Indicators**: SMA, EMA, RSI, MACD, Bollinger Bands
- **Algorithms**: SMA Crossover, RSI Strategy, Grid Trading
- **Data Models**: WatchlistItem, TradeSignal, TradeRecord
- **Total**: 50+ test cases

### API Server Tests (Dart)
- **Health Checks**: `/health`, `/status`
- **Market Data**: Ticker endpoints
- **Watchlist**: CRUD operations
- **Trades**: History and statistics
- **Error Handling**: 404s, invalid data
- **Total**: 15+ integration tests

### Frontend Tests (JavaScript)
- **API Functions**: Fetch, parse, display
- **UI Components**: Modals, tables, forms
- **Auto-refresh**: Interval management
- **User Interactions**: Add/remove symbols
- **Total**: 20+ test cases

---

## 🚀 Running Tests

### Bot Service Tests

```bash
cd bot_service

# Install dependencies (first time only)
dart pub get

# Run all tests
dart test

# Run specific test file
dart test test/technical_indicators_test.dart
dart test test/sma_crossover_test.dart
dart test test/rsi_strategy_test.dart

# Run with coverage
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### API Server Tests

```bash
cd api_server

# Install dependencies
dart pub get

# Start API server first (in another terminal)
dart run bin/server.dart

# Then run tests
dart test

# Run specific test
dart test test/api_integration_test.dart
```

### Frontend Tests

```bash
cd web_ui

# Install Jest (first time only)
npm install --save-dev jest @types/jest

# Run tests
npm test

# Run with coverage
npm test -- --coverage

# Watch mode (re-run on file changes)
npm test -- --watch
```

---

## 📊 Test Results Examples

### Successful Test Run

```
Bot Service Tests:
✓ Technical Indicators - SMA calculates correctly
✓ Technical Indicators - RSI detects oversold
✓ SMA Crossover - detects bullish crossover
✓ RSI Strategy - generates buy signal
✓ Grid Trading - places orders at levels

32 tests passed
0 tests failed
Time: 2.5s
```

### Test with Failures

```
FAIL test/sma_crossover_test.dart
  ✗ detects bearish crossover
    Expected: 'SELL'
    Actual: 'BUY'
    Line: 45

1 test failed
31 tests passed
```

---

## ✍️ Writing New Tests

### Example: Testing a New Algorithm

```dart
// test/my_algorithm_test.dart
import 'package:test/test.dart';
import '../lib/algorithms/my_algorithm.dart';

void main() {
  group('MyAlgorithm', () {
    late MyAlgorithm algorithm;

    setUp(() {
      algorithm = MyAlgorithm(
        param1: 10,
        param2: 20,
      );
    });

    test('initializes correctly', () {
      expect(algorithm.name, equals('My Algorithm'));
      expect(algorithm.active, isTrue);
    });

    test('generates signals correctly', () async {
      // Add test prices
      for (int i = 0; i < 20; i++) {
        await algorithm.analyze('BTCUSDT', 100.0 + i);
      }

      final signal = await algorithm.analyze('BTCUSDT', 120.0);

      expect(signal, isNotNull);
      expect(signal!.side, equals('BUY'));
    });

    tearDown(() {
      algorithm.clearHistory();
    });
  });
}
```

### Example: Testing an API Endpoint

```dart
// test/my_endpoint_test.dart
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  final baseUrl = 'http://localhost:3000';

  test('GET /api/my-endpoint returns data', () async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/my-endpoint'),
    );

    expect(response.statusCode, equals(200));

    final body = json.decode(response.body);
    expect(body.containsKey('data'), isTrue);
  });
}
```

### Example: Testing Frontend Function

```javascript
// test/my_function.test.js
describe('myFunction', () => {
  test('processes data correctly', () => {
    const input = { symbol: 'BTCUSDT', price: 95000 };
    const result = myFunction(input);

    expect(result).toHaveProperty('symbol');
    expect(result.symbol).toBe('BTCUSDT');
    expect(result.price).toBeGreaterThan(0);
  });

  test('handles errors gracefully', () => {
    expect(() => {
      myFunction(null);
    }).not.toThrow();
  });
});
```

---

## 🎯 Test Best Practices

### 1. **Test Structure**

Use AAA pattern (Arrange, Act, Assert):

```dart
test('my test', () {
  // Arrange - Setup
  final algorithm = MyAlgorithm();

  // Act - Execute
  final result = algorithm.calculate(100);

  // Assert - Verify
  expect(result, equals(expected));
});
```

### 2. **Test Independence**

Each test should be independent:

```dart
group('MyTests', () {
  setUp(() {
    // Fresh state for each test
  });

  tearDown(() {
    // Cleanup after each test
  });
});
```

### 3. **Descriptive Names**

Use clear, descriptive test names:

```dart
// ❌ Bad
test('test1', () { ... });

// ✅ Good
test('generates buy signal when RSI falls below 30', () { ... });
```

### 4. **Test Edge Cases**

```dart
test('handles empty list', () { ... });
test('handles null input', () { ... });
test('handles very large numbers', () { ... });
test('handles negative values', () { ... });
```

### 5. **Mock External Dependencies**

```dart
test('calls API correctly', () {
  final mockHttp = MockHttpClient();
  when(mockHttp.get(any)).thenAnswer((_) async => mockResponse);

  // Test with mock
});
```

---

## 📈 Continuous Integration

### GitHub Actions Workflow

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  bot-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - name: Install dependencies
        run: cd bot_service && dart pub get
      - name: Run tests
        run: cd bot_service && dart test

  api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - name: Install dependencies
        run: cd api_server && dart pub get
      - name: Run tests
        run: cd api_server && dart test

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - name: Install dependencies
        run: cd web_ui && npm install
      - name: Run tests
        run: cd web_ui && npm test
```

---

## 🐛 Debugging Tests

### View Detailed Output

```bash
# Dart tests with verbose output
dart test --reporter expanded

# Show print statements
dart test --chain-stack-traces
```

### Run Single Test

```bash
# Dart - use test name filter
dart test --name "generates buy signal"

# Jest - use test name pattern
npm test -- --testNamePattern="adds symbol"
```

### Debug in VS Code

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Bot Tests",
      "type": "dart",
      "request": "launch",
      "program": "bot_service/test/sma_crossover_test.dart"
    }
  ]
}
```

---

## 📊 Coverage Goals

### Current Coverage

| Component | Coverage | Goal |
|-----------|----------|------|
| Technical Indicators | 90% | 95% |
| Algorithms | 85% | 90% |
| Data Models | 100% | 100% |
| API Server | 70% | 85% |
| Frontend | 60% | 80% |

### Generate Coverage Report

```bash
# Bot service
cd bot_service
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Frontend
cd web_ui
npm test -- --coverage
open coverage/lcov-report/index.html
```

---

## 🔄 Test-Driven Development (TDD)

### TDD Workflow

1. **Write failing test first**

```dart
test('new feature works', () {
  final result = myNewFeature();
  expect(result, equals(expected));
});
// This will fail because myNewFeature doesn't exist yet
```

2. **Write minimal code to pass**

```dart
String myNewFeature() {
  return expected;
}
```

3. **Refactor and improve**

```dart
String myNewFeature() {
  // Proper implementation
  return calculateResult();
}
```

4. **Run tests again** - Should still pass

---

## 🎓 Testing Resources

### Dart Testing
- [Dart Test Package](https://pub.dev/packages/test)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart)
- [Mockito for Dart](https://pub.dev/packages/mockito)

### JavaScript Testing
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Testing Library](https://testing-library.com/)
- [Jest Matchers](https://jestjs.io/docs/expect)

### General
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Unit Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

---

## ✅ Test Checklist

Before committing code:

- [ ] All existing tests pass
- [ ] New tests added for new features
- [ ] Edge cases tested
- [ ] Error handling tested
- [ ] Coverage above 80%
- [ ] Tests are independent
- [ ] Tests have clear names
- [ ] No console errors/warnings

---

## 🚀 Quick Commands Reference

```bash
# Bot Service
cd bot_service && dart test

# API Server (requires server running)
cd api_server && dart test

# Frontend
cd web_ui && npm test

# All tests with coverage
dart test --coverage && npm test -- --coverage

# Watch mode
npm test -- --watch

# Specific test file
dart test test/sma_crossover_test.dart
```

---

## 📞 Need Help?

- **Test failing?** Check error message and line number
- **Coverage low?** Run `dart test --coverage` to see uncovered lines
- **Slow tests?** Use mocks for external services
- **Flaky tests?** Check for race conditions, use `await` properly

**Happy Testing!** 🧪✅
