import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/network/websocket/connection_status.dart';
import '../../domain/repositories/portfolio_repository.dart';
import 'connection_state.dart';

/// Owns the header's "Live / Reconnecting… / Offline" indicator. Combines
/// the socket's own status with a real device-connectivity check so a
/// genuine network outage reads as Offline, not just Reconnecting forever.
class ConnectionCubit extends Cubit<ConnectionUiState> {
  final PortfolioRepository _repository;
  final ConnectivityMonitor _connectivityMonitor;

  StreamSubscription<ConnectionStatus>? _socketSub;
  StreamSubscription<bool>? _connectivitySub;

  ConnectionStatus _socketStatus = ConnectionStatus.reconnecting;
  bool _isOnline = true;

  ConnectionCubit(this._repository, this._connectivityMonitor)
      : super(const ConnectionUiState(ConnectionStatus.reconnecting)) {
    _init();
  }

  Future<void> _init() async {
    _isOnline = await _connectivityMonitor.isOnlineNow;
    _socketSub = _repository.watchConnectionStatus().listen((status) {
      _socketStatus = status;
      _emitEffective();
    });
    _connectivitySub = _connectivityMonitor.onlineStatusStream.listen((online) {
      _isOnline = online;
      _emitEffective();
    });
    _emitEffective();
  }

  void _emitEffective() {
    final effective = _isOnline ? _socketStatus : ConnectionStatus.offline;
    emit(ConnectionUiState(effective));
  }

  /// Debug-only trigger (wired to a button in Dev/QA) that simulates a
  /// dropped socket without needing airplane mode.
  void debugKillConnection() => _repository.debugKillConnection();

  /// "Retry now" action on the disconnect toast — skips the rest of the
  /// current backoff wait.
  void retryNow() => _repository.retryNow();

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}
