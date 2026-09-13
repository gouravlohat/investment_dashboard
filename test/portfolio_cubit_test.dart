import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:investment_dashboard/core/network/websocket/connection_status.dart';
import 'package:investment_dashboard/core/utils/result.dart';
import 'package:investment_dashboard/features/portfolio/domain/entities/holding.dart';
import 'package:investment_dashboard/features/portfolio/domain/entities/quote.dart';
import 'package:investment_dashboard/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:investment_dashboard/features/portfolio/domain/usecases/update_target_price_alert.dart';
import 'package:investment_dashboard/features/portfolio/domain/usecases/watch_live_quotes.dart';
import 'package:investment_dashboard/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:investment_dashboard/features/portfolio/presentation/cubit/portfolio_state.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  const holding = Holding(symbol: 'AAPL', companyName: 'Apple', quantity: 10, avgBuyPrice: 100);
  final quote = Quote(symbol: 'AAPL', price: 111, changePercent: 11, timestamp: DateTime.now());

  late MockPortfolioRepository repository;

  setUp(() {
    repository = MockPortfolioRepository();
    when(() => repository.getHoldings()).thenReturn([holding]);
    when(() => repository.getHistory()).thenReturn([]);
    when(() => repository.connectFeed(any())).thenAnswer((_) async {});
    when(() => repository.watchLiveQuotes()).thenAnswer((_) => Stream.value(quote));
    when(() => repository.watchConnectionStatus())
        .thenAnswer((_) => Stream.value(ConnectionStatus.live));
    when(() => repository.updateTargetPriceAlert(any(), any()))
        .thenAnswer((_) async => const Success(null));
  });

  PortfolioCubit buildCubit() =>
      PortfolioCubit(repository, WatchLiveQuotes(repository), UpdateTargetPriceAlert(repository));

  blocTest<PortfolioCubit, PortfolioState>(
    'loads holdings and folds a live quote tick into state.quotes',
    build: buildCubit,
    wait: const Duration(milliseconds: 50),
    verify: (cubit) {
      expect(cubit.state.status, PortfolioStatus.ready);
      expect(cubit.state.holdings, [holding]);
      expect(cubit.state.quotes['AAPL']?.price, 111);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'updateTargetPriceAlert applies optimistically and keeps the value on success',
    build: buildCubit,
    wait: const Duration(milliseconds: 20),
    act: (cubit) => cubit.updateTargetPriceAlert('AAPL', 199.99),
    verify: (cubit) {
      final updated = cubit.state.holdings.firstWhere((h) => h.symbol == 'AAPL');
      expect(updated.targetPriceAlert, 199.99);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'updateTargetPriceAlert applies optimistically then rolls back on failure',
    setUp: () {
      when(() => repository.updateTargetPriceAlert(any(), any()))
          .thenAnswer((_) async => const Failure('boom'));
    },
    build: buildCubit,
    wait: const Duration(milliseconds: 20),
    act: (cubit) async {
      final succeeded = await cubit.updateTargetPriceAlert('AAPL', 199.99);
      expect(succeeded, isFalse);
    },
    verify: (cubit) {
      final holding = cubit.state.holdings.firstWhere((h) => h.symbol == 'AAPL');
      expect(holding.targetPriceAlert, isNull, reason: 'should roll back to the pre-edit value');
    },
  );
}
