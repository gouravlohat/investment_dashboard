import 'dart:math';

import '../../../../core/network/websocket/connection_status.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_history_point.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../datasources/stock_price_remote_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource _localDataSource;
  final StockPriceRemoteDataSource _remoteDataSource;
  final Random _random = Random();

  PortfolioRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  List<Holding> getHoldings() =>
      _localDataSource.getSeedHoldings().map((m) => m.toEntity()).toList();

  @override
  List<PortfolioHistoryPoint> getHistory() {
    final holdings = getHoldings();
    final anchor = holdings.fold<double>(0, (sum, h) => sum + h.quantity * h.avgBuyPrice);
    return _localDataSource.getHistory(anchorValue: anchor);
  }

  @override
  Future<void> connectFeed(List<String> symbols) => _remoteDataSource.connect(symbols);

  @override
  Stream<Quote> watchLiveQuotes() => _remoteDataSource.quoteStream;

  @override
  Stream<ConnectionStatus> watchConnectionStatus() => _remoteDataSource.statusStream;

  @override
  void debugKillConnection() => _remoteDataSource.debugKillConnection();

  @override
  void retryNow() => _remoteDataSource.retryNow();

  @override
  Future<Result<void>> updateTargetPriceAlert(String symbol, double? value) async {
    // No backend: simulate a partial-update API round trip so the
    // snapshot-and-diff / optimistic-UI plumbing has something real to do.
    // A ~15% simulated failure rate exercises the rollback path in the
    // running app instead of only in unit tests.
    await Future.delayed(const Duration(milliseconds: 400));
    if (_random.nextDouble() < 0.15) {
      return const Failure('Network error — please try again.');
    }
    return const Success(null);
  }
}
