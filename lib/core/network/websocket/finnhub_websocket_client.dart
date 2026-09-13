import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection_status.dart';
import 'raw_quote_tick.dart';
import 'reconnect_policy.dart';
import 'websocket_client.dart';

class FinnhubWebsocketClient implements WebsocketClient {
  final String apiKey;
  final ReconnectPolicy _reconnectPolicy;

  final _quoteController = StreamController<RawQuoteTick>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _manuallyDisconnected = false;
  bool _connected = false;
  List<String> _symbols = [];
  final Map<String, double> _basePrice = {};

  FinnhubWebsocketClient({
    required this.apiKey,
    ReconnectPolicy? reconnectPolicy,
  }) : _reconnectPolicy = reconnectPolicy ?? ReconnectPolicy();

  @override
  Stream<RawQuoteTick> get quoteStream => _quoteController.stream;

  @override
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  @override
  Future<void> connect(List<String> symbols) async {
    _symbols = symbols;
    _manuallyDisconnected = false;
    await _openSocket();
  }

  Future<void> _openSocket() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://ws.finnhub.io?token=$apiKey'),
      );
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (_) => _handleDrop(),
        onDone: _handleDrop,
        cancelOnError: true,
      );
      for (final symbol in _symbols) {
        _channel!.sink.add(jsonEncode({'type': 'subscribe', 'symbol': symbol}));
      }
      _reconnectAttempt = 0;
      _connected = true;
      _statusController.add(ConnectionStatus.live);
    } catch (_) {
      _handleDrop();
    }
  }

  void _handleMessage(dynamic raw) {
    final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
    if (decoded['type'] != 'trade') return;
    final trades = decoded['data'] as List<dynamic>?;
    if (trades == null) return;
    for (final t in trades) {
      final symbol = t['s'] as String;
      final price = (t['p'] as num).toDouble();
      final base = _basePrice.putIfAbsent(symbol, () => price);
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
  }

  void _handleDrop() {
    _connected = false;
    if (_manuallyDisconnected) return;
    _subscription?.cancel();
    _statusController.add(ConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectAttempt++;
    final delay = _reconnectPolicy.delayFor(_reconnectAttempt);
    _reconnectTimer = Timer(delay, _openSocket);
  }

  @override
  void debugKillConnection() {
    _channel?.sink.close();
  }

  @override
  void retryNow() {
    if (_connected) return;
    _reconnectTimer?.cancel();
    _openSocket();
  }

  @override
  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _connected = false;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _statusController.add(ConnectionStatus.offline);
  }

  @override
  void dispose() {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _quoteController.close();
    _statusController.close();
  }
}
