import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/network/connectivity_monitor.dart';
import '../../core/network/websocket/finnhub_websocket_client.dart';
import '../../core/network/websocket/simulated_websocket_client.dart';
import '../../core/network/websocket/websocket_client.dart';
import '../../core/theme/theme_cubit.dart';
import '../../features/portfolio/data/datasources/portfolio_local_datasource.dart';
import '../../features/portfolio/data/datasources/stock_price_remote_datasource.dart';
import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../features/portfolio/domain/usecases/update_target_price_alert.dart';
import '../../features/portfolio/domain/usecases/watch_live_quotes.dart';

final getIt = GetIt.instance;

/// Wires the whole dependency graph for the given flavor. Called once from
/// `bootstrap()`, before `runApp`. This is the one place that decides
/// "simulated feed vs real Finnhub feed" based on [AppConfig].
Future<void> setupInjector(AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<ConnectivityMonitor>(() => ConnectivityMonitor());

  getIt.registerLazySingleton<WebsocketClient>(() {
    if (config.useSimulatedFeed) {
      return SimulatedWebsocketClient(tickInterval: config.simulatedTickInterval);
    }
    return FinnhubWebsocketClient(apiKey: config.finnhubApiKey ?? '');
  });

  getIt.registerLazySingleton<StockPriceRemoteDataSource>(
    () => StockPriceRemoteDataSource(getIt<WebsocketClient>()),
  );
  getIt.registerLazySingleton<PortfolioLocalDataSource>(() => PortfolioLocalDataSource());

  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      getIt<PortfolioLocalDataSource>(),
      getIt<StockPriceRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<WatchLiveQuotes>(() => WatchLiveQuotes(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton<UpdateTargetPriceAlert>(
    () => UpdateTargetPriceAlert(getIt<PortfolioRepository>()),
  );

  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt<SharedPreferences>()));
}
