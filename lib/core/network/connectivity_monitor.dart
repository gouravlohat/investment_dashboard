import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper so the rest of the app depends on a bool stream, not the
/// package's API shape. Lets [ConnectionCubit] tell a real "no network"
/// Offline apart from "socket down but network fine" Reconnecting.
class ConnectivityMonitor {
  final Connectivity _connectivity;

  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Stream<bool> get onlineStatusStream =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> get isOnlineNow async => _isOnline(await _connectivity.checkConnectivity());

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
