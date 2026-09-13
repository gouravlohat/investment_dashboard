import '../../../../core/network/websocket/connection_status.dart';
import '../../../../core/utils/result.dart';
import '../entities/holding.dart';
import '../entities/portfolio_history_point.dart';
import '../entities/quote.dart';

abstract class PortfolioRepository {
  List<Holding> getHoldings();

  List<PortfolioHistoryPoint> getHistory();

  /// Opens the live feed subscribed to [symbols]. Must be called before
  /// [watchLiveQuotes]/[watchConnectionStatus] emit anything.
  Future<void> connectFeed(List<String> symbols);

  Stream<Quote> watchLiveQuotes();

  Stream<ConnectionStatus> watchConnectionStatus();

  void debugKillConnection();

  /// User-triggered "retry now" from the disconnect toast — bypasses the
  /// current backoff wait.
  void retryNow();

  /// Simulates a partial-update API call. Only ever invoked when the
  /// caller has already diffed the value against its original snapshot.
  Future<Result<void>> updateTargetPriceAlert(String symbol, double? value);
}
