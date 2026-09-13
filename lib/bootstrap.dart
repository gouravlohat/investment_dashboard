import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/di/injector.dart';
import 'core/config/app_config.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector(config);
  runApp(PortfolioApp(config: config));
}
