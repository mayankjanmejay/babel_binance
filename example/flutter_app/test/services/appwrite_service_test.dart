import 'package:flutter_test/flutter_test.dart';
import 'package:babel_binance_example/src/services/appwrite_service.dart';

void main() {
  group('AppwriteService Tests', () {
    late AppwriteService appwriteService;

    setUp(() {
      appwriteService = AppwriteService();
    });

    test('should not be configured initially', () {
      expect(appwriteService.isConfigured, false);
    });

    test('should store configuration', () async {
      await appwriteService.configure(
        endpoint: 'https://test.appwrite.io/v1',
        projectId: 'test-project',
      );

      expect(appwriteService.isConfigured, true);
    });

    test('should retrieve configuration', () async {
      await appwriteService.configure(
        endpoint: 'https://test.appwrite.io/v1',
        projectId: 'test-project',
        apiKey: 'test-api-key',
      );

      final config = await appwriteService.getConfiguration();

      expect(config['endpoint'], 'https://test.appwrite.io/v1');
      expect(config['projectId'], 'test-project');
      expect(config['apiKey'], 'test-api-key');
    });

    test('should clear configuration', () async {
      await appwriteService.configure(
        endpoint: 'https://test.appwrite.io/v1',
        projectId: 'test-project',
      );

      await appwriteService.clearConfiguration();

      expect(appwriteService.isConfigured, false);
    });
  });
}
