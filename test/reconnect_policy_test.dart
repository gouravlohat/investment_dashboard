import 'package:flutter_test/flutter_test.dart';
import 'package:investment_dashboard/core/network/websocket/reconnect_policy.dart';

void main() {
  group('ReconnectPolicy', () {
    test('delay grows exponentially and stays within the jitter band', () {
      final policy = ReconnectPolicy(
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 30),
      );

      for (var attempt = 1; attempt <= 6; attempt++) {
        final expectedBase = (1000 * (1 << (attempt - 1))).clamp(0, 30000);
        final delay = policy.delayFor(attempt);
        expect(delay.inMilliseconds, greaterThanOrEqualTo((expectedBase * 0.8).round()));
        expect(delay.inMilliseconds, lessThanOrEqualTo((expectedBase * 1.2).round()));
      }
    });

    test('delay never exceeds maxDelay even at high attempt counts', () {
      final policy = ReconnectPolicy(
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 30),
      );

      final delay = policy.delayFor(20);
      expect(delay.inMilliseconds, lessThanOrEqualTo(30000 * 1.2));
    });
  });
}
