import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:investment_dashboard/app/app.dart';
import 'package:investment_dashboard/app/di/injector.dart';
import 'package:investment_dashboard/core/config/app_config.dart';
import 'package:investment_dashboard/core/network/websocket/websocket_client.dart';

import 'widget_test.dart' show NoopWebsocketClient;

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

  testWidgets('dashboard has no overflow at common phone widths', (tester) async {
    for (final size in [
      const Size(360, 800), // small Android phone
      const Size(390, 844), // iPhone 13/14
      const Size(320, 690), // iPhone SE
      const Size(768, 1024), // iPad portrait
      const Size(1024, 768), // iPad landscape
    ]) {
      await tester.binding.setSurfaceSize(size);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(PortfolioApp(config: AppConfig.dev()));
      // Not pumpAndSettle: the Reconnecting status dot animates on an
      // infinite repeat by design, which pumpAndSettle never considers
      // "settled". A few bounded pumps is enough for layout + the async
      // connect() to resolve.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final exception = tester.takeException();
      expect(exception, isNull, reason: 'Overflow/exception at size $size: $exception');
    }

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
