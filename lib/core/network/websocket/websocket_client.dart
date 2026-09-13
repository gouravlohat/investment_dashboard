import 'connection_status.dart';
import 'raw_quote_tick.dart';

/// Abstraction over "a live price feed". [SimulatedWebsocketClient] and
/// [FinnhubWebsocketClient] both implement this so the rest of the app
/// (and the flavor-based DI wiring) never cares which one is live.
abstract class WebsocketClient {
  /// Emits a tick every time any subscribed symbol's price changes.
  Stream<RawQuoteTick> get quoteStream;

  /// Emits whenever the connection state changes (live/reconnecting/offline).
  Stream<ConnectionStatus> get statusStream;

  Future<void> connect(List<String> symbols);

  Future<void> disconnect();

  /// Test hook: forcibly drops the connection so reconnect/backoff can be
  /// exercised without needing airplane mode.
  void debugKillConnection();

  void dispose();
}
