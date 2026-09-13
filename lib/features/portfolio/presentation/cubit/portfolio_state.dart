import 'package:equatable/equatable.dart';

import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_history_point.dart';
import '../../domain/entities/quote.dart';

enum PortfolioStatus { loading, ready }

/// Raw state only: holdings + latest quotes + history. No P/L, no %, no
/// "today's change" field here — those are always derived on demand by
/// `PortfolioCalculator` from this data, never cached, so they can never
/// drift out of sync with it.
class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final List<Holding> holdings;
  final Map<String, Quote> quotes;
  final List<PortfolioHistoryPoint> history;

  const PortfolioState({
    required this.status,
    required this.holdings,
    required this.quotes,
    required this.history,
  });

  factory PortfolioState.initial() => const PortfolioState(
        status: PortfolioStatus.loading,
        holdings: [],
        quotes: {},
        history: [],
      );

  PortfolioState copyWith({
    PortfolioStatus? status,
    List<Holding>? holdings,
    Map<String, Quote>? quotes,
    List<PortfolioHistoryPoint>? history,
  }) =>
      PortfolioState(
        status: status ?? this.status,
        holdings: holdings ?? this.holdings,
        quotes: quotes ?? this.quotes,
        history: history ?? this.history,
      );

  @override
  List<Object?> get props => [status, holdings, quotes, history];
}
