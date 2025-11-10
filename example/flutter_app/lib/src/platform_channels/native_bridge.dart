import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.babel.binance/native');

  // Battery Level Example
  static Future<int?> getBatteryLevel() async {
    try {
      final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
      return batteryLevel;
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
      return null;
    }
  }

  // Device Info
  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> deviceInfo = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(deviceInfo);
    } on PlatformException catch (e) {
      print("Failed to get device info: '${e.message}'.");
      return null;
    }
  }

  // Haptic Feedback
  static Future<void> triggerHapticFeedback({String type = 'light'}) async {
    try {
      await _channel.invokeMethod('hapticFeedback', {'type': type});
    } on PlatformException catch (e) {
      print("Failed to trigger haptic feedback: '${e.message}'.");
    }
  }

  // Share Content
  static Future<bool> shareContent(String text, {String? subject}) async {
    try {
      final bool result = await _channel.invokeMethod('shareContent', {
        'text': text,
        'subject': subject,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to share content: '${e.message}'.");
      return false;
    }
  }

  // Open Native Settings
  static Future<void> openSettings({String? section}) async {
    try {
      await _channel.invokeMethod('openSettings', {'section': section});
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }

  // Secure Storage (Native Keychain/KeyStore)
  static Future<bool> saveSecureData(String key, String value) async {
    try {
      final bool result = await _channel.invokeMethod('saveSecureData', {
        'key': key,
        'value': value,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to save secure data: '${e.message}'.");
      return false;
    }
  }

  static Future<String?> getSecureData(String key) async {
    try {
      final String? value = await _channel.invokeMethod('getSecureData', {'key': key});
      return value;
    } on PlatformException catch (e) {
      print("Failed to get secure data: '${e.message}'.");
      return null;
    }
  }

  static Future<bool> deleteSecureData(String key) async {
    try {
      final bool result = await _channel.invokeMethod('deleteSecureData', {'key': key});
      return result;
    } on PlatformException catch (e) {
      print("Failed to delete secure data: '${e.message}'.");
      return false;
    }
  }

  // Check if App is in Background
  static Future<bool> isAppInBackground() async {
    try {
      final bool result = await _channel.invokeMethod('isAppInBackground');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check app state: '${e.message}'.");
      return false;
    }
  }

  // Lock Screen
  static Future<void> lockScreen() async {
    try {
      await _channel.invokeMethod('lockScreen');
    } on PlatformException catch (e) {
      print("Failed to lock screen: '${e.message}'.");
    }
  }

  // Screen Brightness
  static Future<double?> getScreenBrightness() async {
    try {
      final double brightness = await _channel.invokeMethod('getScreenBrightness');
      return brightness;
    } on PlatformException catch (e) {
      print("Failed to get screen brightness: '${e.message}'.");
      return null;
    }
  }

  static Future<void> setScreenBrightness(double brightness) async {
    try {
      await _channel.invokeMethod('setScreenBrightness', {'brightness': brightness});
    } on PlatformException catch (e) {
      print("Failed to set screen brightness: '${e.message}'.");
    }
  }

  // Network Info
  static Future<Map<String, dynamic>?> getNetworkInfo() async {
    try {
      final Map<dynamic, dynamic> networkInfo = await _channel.invokeMethod('getNetworkInfo');
      return Map<String, dynamic>.from(networkInfo);
    } on PlatformException catch (e) {
      print("Failed to get network info: '${e.message}'.");
      return null;
    }
  }

  // Clipboard
  static Future<void> copyToClipboard(String text) async {
    try {
      await _channel.invokeMethod('copyToClipboard', {'text': text});
    } on PlatformException catch (e) {
      print("Failed to copy to clipboard: '${e.message}'.");
    }
  }

  static Future<String?> getClipboardContent() async {
    try {
      final String? content = await _channel.invokeMethod('getClipboardContent');
      return content;
    } on PlatformException catch (e) {
      print("Failed to get clipboard content: '${e.message}'.");
      return null;
    }
  }

  // Check Root/Jailbreak Status
  static Future<bool> isDeviceRooted() async {
    try {
      final bool isRooted = await _channel.invokeMethod('isDeviceRooted');
      return isRooted;
    } on PlatformException catch (e) {
      print("Failed to check root status: '${e.message}'.");
      return false;
    }
  }

  // App Version
  static Future<String?> getAppVersion() async {
    try {
      final String version = await _channel.invokeMethod('getAppVersion');
      return version;
    } on PlatformException catch (e) {
      print("Failed to get app version: '${e.message}'.");
      return null;
    }
  }
}
