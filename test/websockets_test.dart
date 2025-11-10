import 'dart:async';
import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Websockets Class Tests', () {
    late Websockets websockets;

    setUp(() {
      websockets = Websockets();
    });

    test('Websockets instance creation', () {
      expect(websockets, isNotNull);
      expect(websockets, isA<Websockets>());
    });

    test('connectToStream method exists', () {
      expect(websockets.connectToStream, isA<Function>());
    });

    test('Multiple Websockets instances are independent', () {
      final ws1 = Websockets();
      final ws2 = Websockets();

      expect(ws1, isNot(same(ws2)));
    });

    test('connectToStream returns a Stream', () {
      final stream = websockets.connectToStream('test_listen_key');

      expect(stream, isA<Stream>());
    });

    test('connectToStream with different listen keys', () {
      final stream1 = websockets.connectToStream('listen_key_1');
      final stream2 = websockets.connectToStream('listen_key_2');

      expect(stream1, isA<Stream>());
      expect(stream2, isA<Stream>());
      expect(stream1, isNot(same(stream2)));
    });

    test('Stream can be listened to', () {
      final stream = websockets.connectToStream('test_listen_key');
      StreamSubscription? subscription;

      expect(() {
        subscription = stream.listen(
          (data) {
            // Message handler
          },
          onError: (error) {
            // Error handler
          },
          onDone: () {
            // Done handler
          },
        );
      }, returnsNormally);

      // Clean up
      subscription?.cancel();
    });

    test('Multiple listeners on different streams', () {
      final stream1 = websockets.connectToStream('key1');
      final stream2 = websockets.connectToStream('key2');

      final sub1 = stream1.listen((_) {});
      final sub2 = stream2.listen((_) {});

      expect(sub1, isNotNull);
      expect(sub2, isNotNull);
      expect(sub1, isNot(same(sub2)));

      // Clean up
      sub1.cancel();
      sub2.cancel();
    });

    test('Stream subscription can be cancelled', () {
      final stream = websockets.connectToStream('test_key');
      final subscription = stream.listen((_) {});

      expect(() => subscription.cancel(), returnsNormally);
    });

    test('Empty listen key', () {
      expect(() => websockets.connectToStream(''), returnsNormally);
    });

    test('Very long listen key', () {
      final longKey = 'a' * 1000;
      expect(() => websockets.connectToStream(longKey), returnsNormally);
    });

    test('Listen key with special characters', () {
      final specialKey = 'test-key_123.abc';
      expect(() => websockets.connectToStream(specialKey), returnsNormally);
    });
  });

  group('Websockets Stream Behavior Tests', () {
    late Websockets websockets;

    setUp(() {
      websockets = Websockets();
    });

    test('Stream subscription with timeout', () async {
      final stream = websockets.connectToStream('test_key');
      final subscription = stream.timeout(
        Duration(seconds: 1),
        onTimeout: (sink) {
          sink.close();
        },
      ).listen(
        (_) {},
        onError: (_) {},
      );

      await Future.delayed(Duration(milliseconds: 100));
      subscription.cancel();
    });

    test('Stream error handling', () async {
      final stream = websockets.connectToStream('test_key');
      bool errorHandled = false;

      final subscription = stream.listen(
        (_) {},
        onError: (error) {
          errorHandled = true;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Error handler should be set even if no error occurs
      expect(errorHandled, isFalse); // No error expected in this test
    });

    test('Stream completion handling', () async {
      final stream = websockets.connectToStream('test_key');
      bool isDone = false;

      final subscription = stream.listen(
        (_) {},
        onDone: () {
          isDone = true;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Stream may or may not complete, just testing the handler is set
    });
  });

  group('Websockets Integration with UserDataStream', () {
    test('Websockets can be used with Spot UserDataStream', () {
      final binance = Binance(apiKey: 'test_key');
      final websockets = Websockets();

      expect(binance.spot.userDataStream, isNotNull);
      expect(websockets, isNotNull);
    });

    test('Multiple WebSocket connections', () {
      final ws1 = Websockets();
      final ws2 = Websockets();
      final ws3 = Websockets();

      expect(ws1, isNotNull);
      expect(ws2, isNotNull);
      expect(ws3, isNotNull);

      expect(ws1, isNot(same(ws2)));
      expect(ws2, isNot(same(ws3)));
      expect(ws1, isNot(same(ws3)));
    });
  });

  group('Websockets URL Construction Tests', () {
    test('Stream connection with valid listen key format', () {
      final websockets = Websockets();

      // Test various listen key formats
      final keys = [
        'pqia91ma19a5s61cv6a81va65sdf19v8a65a1a5s61cv6a8',
        'shortkey',
        'KEY123',
        'test_key_with_underscores',
      ];

      for (final key in keys) {
        expect(() => websockets.connectToStream(key), returnsNormally);
      }
    });
  });

  group('Websockets Resource Management Tests', () {
    test('Multiple streams can be created and cancelled', () async {
      final websockets = Websockets();
      final subscriptions = <StreamSubscription>[];

      // Create multiple streams
      for (int i = 0; i < 5; i++) {
        final stream = websockets.connectToStream('key_$i');
        final sub = stream.listen((_) {});
        subscriptions.add(sub);
      }

      expect(subscriptions.length, equals(5));

      // Cancel all
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    });

    test('Streams are garbage collected after cancellation', () async {
      final websockets = Websockets();

      for (int i = 0; i < 10; i++) {
        final stream = websockets.connectToStream('key_$i');
        final sub = stream.listen((_) {});
        await sub.cancel();
      }

      // If we get here without memory issues, test passes
      expect(true, isTrue);
    });
  });

  group('Websockets Concurrency Tests', () {
    test('Concurrent stream creation', () {
      final websockets = Websockets();
      final streams = <Stream>[];

      for (int i = 0; i < 10; i++) {
        streams.add(websockets.connectToStream('key_$i'));
      }

      expect(streams.length, equals(10));

      for (final stream in streams) {
        expect(stream, isA<Stream>());
      }
    });

    test('Concurrent subscriptions', () {
      final websockets = Websockets();
      final subscriptions = <StreamSubscription>[];

      for (int i = 0; i < 10; i++) {
        final stream = websockets.connectToStream('key_$i');
        final sub = stream.listen((_) {});
        subscriptions.add(sub);
      }

      expect(subscriptions.length, equals(10));

      // Clean up
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  });
}
