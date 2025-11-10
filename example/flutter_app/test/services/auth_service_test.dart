import 'package:flutter_test/flutter_test.dart';
import 'package:babel_binance_example/src/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should not be authenticated initially', () {
      expect(authService.isAuthenticated, false);
    });

    test('should return null for current user when not authenticated', () {
      expect(authService.currentUser, null);
    });

    // Note: Full authentication tests would require Firebase emulator
    // or mocked Firebase auth instance
  });
}
