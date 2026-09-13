/// Real connection state of the live price feed — must reflect actual
/// socket/network state, never a static icon.
enum ConnectionStatus {
  /// Socket connected and receiving ticks.
  live,

  /// Socket dropped and a backoff-scheduled reconnect attempt is pending.
  reconnecting,

  /// No network connectivity at all (device offline), distinct from a
  /// live socket that's merely mid-backoff.
  offline,
}
