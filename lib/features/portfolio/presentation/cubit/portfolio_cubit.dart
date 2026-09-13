import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/usecases/update_target_price_alert.dart';
import '../../domain/usecases/watch_live_quotes.dart';
import 'portfolio_state.dart';

/// Source-of-truth cubit for holdings + live quotes. Deliberately does NOT
/// own search/sort/scroll UI state (see [HoldingsUiCubit]) so a price tick
/// here never has a chance to reset the user's in-progress interaction.
class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository _repository;
  final WatchLiveQuotes _watchLiveQuotes;
  final UpdateTargetPriceAlert _updateTargetPriceAlert;

  StreamSubscription<Quote>? _quoteSub;

  PortfolioCubit(this._repository, this._watchLiveQuotes, this._updateTargetPriceAlert)
      : super(PortfolioState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final holdings = _repository.getHoldings();
    final history = _repository.getHistory();
    emit(state.copyWith(
      status: PortfolioStatus.ready,
      holdings: holdings,
      history: history,
    ));

    await _repository.connectFeed(holdings.map((h) => h.symbol).toList());
    _quoteSub = _watchLiveQuotes().listen((quote) {
      final updatedQuotes = Map<String, Quote>.from(state.quotes);
      updatedQuotes[quote.symbol] = quote;
      emit(state.copyWith(quotes: updatedQuotes));
    });
  }

  /// Snapshot-and-diff happens in the editor widget; by the time this is
  /// called we already know the value changed, so we always send.
  ///
  /// Optimistic UI: the new value is applied to state immediately, before
  /// the (simulated) network call resolves, so the row updates instantly.
  /// If the call comes back a [Failure], the holding is rolled back to
  /// whatever it was before this call. Returns whether it ended up
  /// succeeding, so the editor can tell the user if it got reverted.
  Future<bool> updateTargetPriceAlert(String symbol, double? newValue) async {
    final previousHoldings = state.holdings;
    final optimisticHoldings = state.holdings
        .map((h) => h.symbol == symbol ? h.withTargetPriceAlert(newValue) : h)
        .toList();
    emit(state.copyWith(holdings: optimisticHoldings));

    final result = await _updateTargetPriceAlert(symbol, newValue);
    if (result is Failure<void>) {
      emit(state.copyWith(holdings: previousHoldings));
      return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _quoteSub?.cancel();
    return super.close();
  }
}
