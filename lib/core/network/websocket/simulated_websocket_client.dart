import 'dart:async';
import 'dart:math';

import 'connection_status.dart';
import 'raw_quote_tick.dart';
import 'reconnect_policy.dart';
import 'websocket_client.dart';

/// Used by the Dev/QA flavors. Generates a random-walk price stream for a
/// configured symbol set at a configured interval, and can simulate a
/// dropped connection (via [debugKillConnection]) that exercises the same
/// exponential-backoff reconnect path a real socket would use.
class SimulatedWebsocketClient implements WebsocketClient {
  final Duration tickInterval;
  final ReconnectPolicy _reconnectPolicy;
  final Random _random = Random();

  final _quoteController = StreamController<RawQuoteTick>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  List<String> _symbols = [];
  final Map<String, double> _lastPrice = {};
  final Map<String, double> _basePrice = {};

  Timer? _tickTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _connected = false;

  SimulatedWebsocketClient({
    required this.tickInterval,
    ReconnectPolicy? reconnectPolicy,
  }) : _reconnectPolicy = reconnectPolicy ?? ReconnectPolicy();

  @override
  Stream<RawQuoteTick> get quoteStream => _quoteController.stream;

  @override
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  @override
  Future<void> connect(List<String> symbols) async {
    _symbols = symbols;
    for (final symbol in symbols) {
      // Seed a plausible starting price per symbol, stable across restarts
      // of the same session via the symbol's hashCode.
      final seedPrice = 50 + (symbol.hashCode.abs() % 900).toDouble();
      _lastPrice[symbol] = seedPrice;
      _basePrice[symbol] = seedPrice;
    }
    _reconnectAttempt = 0;
    _connected = true;
    _statusController.add(ConnectionStatus.live);
    _emitFreshSnapshot();
    _startTicking();
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(tickInterval, (_) => _emitRandomTick());
  }

  void _emitRandomTick() {
    if (_symbols.isEmpty) return;
    final symbol = _symbols[_random.nextInt(_symbols.length)];
    final current = _lastPrice[symbol] ?? _basePrice[symbol]!;
    // +/- up to 0.6% random walk per tick.
    final deltaPct = (_random.nextDouble() - 0.5) * 0.012;
    final next = (current * (1 + deltaPct)).clamp(1.0, 1000000.0);
    _lastPrice[symbol] = next;
    _emitTickFor(symbol);
  }

  void _emitFreshSnapshot() {
    for (final symbol in _symbols) {
      _emitTickFor(symbol);
    }
  }

  void _emitTickFor(String symbol) {
    final price = _lastPrice[symbol]!;
    final base = _basePrice[symbol]!;
    final changePercent = base == 0 ? 0.0 : ((price - base) / base) * 100;
    _quoteController.add(
      RawQuoteTick(
        symbol: symbol,
        price: price,
        changePercent: changePercent,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void debugKillConnection() {
    if (!_connected) return;
    _tickTimer?.cancel();
    _connected = false;
    _statusController.add(ConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectAttempt++;
    final delay = _reconnectPolicy.delayFor(_reconnectAttempt);
    _reconnectTimer = Timer(delay, () {
      _connected = true;
      _reconnectAttempt = 0;
      _statusController.add(ConnectionStatus.live);
      // On reconnect we push a fresh snapshot rather than replay whatever
      // ticks were "missed" while down — see README for rationale.
      _emitFreshSnapshot();
      _startTicking();
    });
  }

  @override
  Future<void> disconnect() async {
    _tickTimer?.cancel();
    _reconnectTimer?.cancel();
    _connected = false;
    _statusController.add(ConnectionStatus.offline);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _reconnectTimer?.cancel();
    _quoteController.close();
    _statusController.close();
  }
}
