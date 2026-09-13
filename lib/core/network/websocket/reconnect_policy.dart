import 'dart:math';

/// Exponential backoff with jitter: 1s, 2s, 4s, 8s, 16s, capped at 30s.
/// Pure/deterministic aside from the jitter draw, so it's easy to unit test.
class ReconnectPolicy {
  final Duration baseDelay;
  final Duration maxDelay;
  final Random _random;

  ReconnectPolicy({
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    Random? random,
  }) : _random = random ?? Random();

  /// [attempt] is 1-indexed (first retry = attempt 1).
  Duration delayFor(int attempt) {
    final exponentialMs = baseDelay.inMilliseconds * pow(2, attempt - 1);
    final cappedMs = min(exponentialMs.toDouble(), maxDelay.inMilliseconds.toDouble());
    // +/- 20% jitter so a fleet of clients doesn't reconnect in lockstep.
    final jitterFactor = 0.8 + _random.nextDouble() * 0.4;
    final finalMs = (cappedMs * jitterFactor).round();
    return Duration(milliseconds: finalMs);
  }
}
