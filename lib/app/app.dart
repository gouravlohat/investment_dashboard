import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/app_config.dart';
import '../core/network/connectivity_monitor.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../features/portfolio/domain/usecases/update_target_price_alert.dart';
import '../features/portfolio/domain/usecases/watch_live_quotes.dart';
import '../features/portfolio/presentation/cubit/chart_range_cubit.dart';
import '../features/portfolio/presentation/cubit/connection_cubit.dart';
import '../features/portfolio/presentation/cubit/holdings_ui_cubit.dart';
import '../features/portfolio/presentation/cubit/portfolio_cubit.dart';
import '../features/portfolio/presentation/pages/dashboard_page.dart';
import 'di/injector.dart';

class PortfolioApp extends StatelessWidget {
  final AppConfig config;

  const PortfolioApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider(
          create: (_) => ConnectionCubit(
            getIt<PortfolioRepository>(),
            getIt<ConnectivityMonitor>(),
          ),
        ),
        BlocProvider(
          create: (_) => PortfolioCubit(
            getIt<PortfolioRepository>(),
            getIt<WatchLiveQuotes>(),
            getIt<UpdateTargetPriceAlert>(),
          ),
        ),
        BlocProvider(create: (_) => HoldingsUiCubit()),
        BlocProvider(create: (_) => ChartRangeCubit()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state.mode;
          return MaterialApp(
            title: config.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: DashboardPage(config: config),
          );
        },
      ),
    );
  }
}
