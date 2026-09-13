import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:investment_dashboard/app/app.dart';
import 'package:investment_dashboard/app/di/injector.dart';
import 'package:investment_dashboard/core/config/app_config.dart';
import 'package:investment_dashboard/core/network/websocket/connection_status.dart';
import 'package:investment_dashboard/core/network/websocket/raw_quote_tick.dart';
import 'package:investment_dashboard/core/network/websocket/websocket_client.dart';

/// A widget test must never run a real `Timer.periodic` (flutter_test's
/// fake-async binding flags any live timer as a leak on every `pump()`),
/// so we swap in a no-op feed instead of the real SimulatedWebsocketClient.
class NoopWebsocketClient implements WebsocketClient {
  final _quoteController = StreamController<RawQuoteTick>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  @override
  Stream<RawQuoteTick> get quoteStream => _quoteController.stream;

  @override
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  @override
  Future<void> connect(List<String> symbols) async {
    _statusController.add(ConnectionStatus.live);
  }

  @override
  Future<void> disconnect() async {}

  @override
  void debugKillConnection() {}

  @override
  void dispose() {
    _quoteController.close();
    _statusController.close();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await setupInjector(AppConfig.dev());
    if (getIt.isRegistered<WebsocketClient>()) {
      getIt.unregister<WebsocketClient>();
    }
    getIt.registerLazySingleton<WebsocketClient>(() => NoopWebsocketClient());
  });

  testWidgets('Dashboard boots and shows the portfolio summary', (tester) async {
    await tester.pumpWidget(PortfolioApp(config: AppConfig.dev()));
    await tester.pump();

    expect(find.text('Total Invested'), findsOneWidget);
    expect(find.text('Current Value'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);
  });
}
