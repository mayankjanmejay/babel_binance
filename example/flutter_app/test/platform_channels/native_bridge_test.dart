import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:babel_binance_example/src/platform_channels/native_bridge.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.babel.binance/native');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getBatteryLevel':
          return 85;
        case 'getDeviceInfo':
          return {
            'model': 'Test Device',
            'manufacturer': 'Test Manufacturer',
            'version': '1.0',
          };
        case 'getAppVersion':
          return '1.0.0';
        case 'isDeviceRooted':
          return false;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativeBridge Tests', () {
    test('getBatteryLevel returns battery level', () async {
      final batteryLevel = await NativeBridge.getBatteryLevel();
      expect(batteryLevel, 85);
    });

    test('getDeviceInfo returns device information', () async {
      final deviceInfo = await NativeBridge.getDeviceInfo();
      expect(deviceInfo?['model'], 'Test Device');
      expect(deviceInfo?['manufacturer'], 'Test Manufacturer');
    });

    test('getAppVersion returns version string', () async {
      final version = await NativeBridge.getAppVersion();
      expect(version, '1.0.0');
    });

    test('isDeviceRooted returns false for non-rooted device', () async {
      final isRooted = await NativeBridge.isDeviceRooted();
      expect(isRooted, false);
    });
  });
}
