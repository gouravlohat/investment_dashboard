/// The three build flavors. Each points at a different WebSocket
/// endpoint/config — never just a different app name or icon.
enum Flavor { dev, qa, prod }

/// Immutable, flavor-derived runtime configuration. Built once in each
/// `main_*.dart` entrypoint and injected everywhere else via [AppConfig].
class AppConfig {
  final Flavor flavor;
  final String appName;

  /// Human-readable env badge shown in the header (e.g. "DEV").
  final String envLabel;

  /// When true, the app wires up [SimulatedWebsocketClient] instead of a
  /// real socket connection.
  final bool useSimulatedFeed;

  /// Real endpoint used only when [useSimulatedFeed] is false.
  final String wsEndpoint;

  /// Finnhub API key, required only for the prod (real feed) flavor.
  /// Passed in via --dart-define, never hardcoded.
  final String? finnhubApiKey;

  /// Tickers this flavor's simulated feed will generate prices for.
  /// Dev/QA use different symbol sets so the "different config per
  /// flavor" requirement is visibly true even without a real socket.
  final List<String> simulatedSymbols;

  /// How often the simulated feed emits a tick.
  final Duration simulatedTickInterval;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.envLabel,
    required this.useSimulatedFeed,
    required this.wsEndpoint,
    required this.simulatedSymbols,
    required this.simulatedTickInterval,
    this.finnhubApiKey,
  });

  factory AppConfig.dev() => const AppConfig(
        flavor: Flavor.dev,
        appName: 'Mindorigin Portfolio Dev',
        envLabel: 'DEV',
        useSimulatedFeed: true,
        wsEndpoint: 'simulated://dev-feed',
        simulatedSymbols: [
          'AAPL',
          'MSFT',
          'GOOGL',
          'AMZN',
          'TSLA',
          'META',
          'NFLX',
          'NVDA',
        ],
        simulatedTickInterval: Duration(milliseconds: 900),
      );

  factory AppConfig.qa() => const AppConfig(
        flavor: Flavor.qa,
        appName: 'Mindorigin Portfolio QA',
        envLabel: 'QA',
        useSimulatedFeed: true,
        wsEndpoint: 'simulated://qa-feed',
        // Deliberately a different (smaller, slower) config than dev so the
        // two simulated flavors are observably distinct.
        simulatedSymbols: ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'],
        simulatedTickInterval: Duration(milliseconds: 2000),
      );

  factory AppConfig.prod({String? finnhubApiKey}) => AppConfig(
        flavor: Flavor.prod,
        appName: 'Mindorigin Portfolio',
        envLabel: 'PROD',
        useSimulatedFeed: false,
        wsEndpoint: 'wss://ws.finnhub.io',
        finnhubApiKey: finnhubApiKey,
        simulatedSymbols: const [
          'AAPL',
          'MSFT',
          'GOOGL',
          'AMZN',
          'TSLA',
          'META',
          'NFLX',
          'NVDA',
        ],
        simulatedTickInterval: const Duration(seconds: 1),
      );
}
