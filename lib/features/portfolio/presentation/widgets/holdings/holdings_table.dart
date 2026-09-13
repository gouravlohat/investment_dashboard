import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/holding.dart';
import '../../../domain/entities/quote.dart';
import '../../../domain/portfolio_calculator.dart';
import '../../cubit/holdings_ui_cubit.dart';
import '../../cubit/holdings_ui_state.dart';
import '../../cubit/portfolio_cubit.dart';
import 'holding_row.dart';

/// Renders the filtered/sorted holdings list.
///
/// Perf-critical detail: when the active filter is "All" and the sort
/// column doesn't depend on live price (symbol/qty/avg buy), the filtered
/// list can't possibly change because of a price tick — so we select only
/// `state.holdings`, which keeps the *same List instance* across ticks
/// (only `state.quotes` changes on a tick). `context.select` then never
/// even calls this widget's `build()` on a tick, so nothing here
/// reconstructs; only each row's isolated live-price cell does. When the
/// user picks a price-dependent filter/sort, membership/order genuinely
/// does depend on price, so we intentionally watch the full state instead.
class HoldingsTable extends StatelessWidget {
  const HoldingsTable({super.key});

  bool _needsQuotes(HoldingsUiState ui) =>
      ui.activeFilter != SummaryFilter.all ||
      ui.sortColumn == HoldingsSortColumn.currentPrice ||
      ui.sortColumn == HoldingsSortColumn.profitLoss;

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<HoldingsUiCubit>().state;
    final needsQuotes = _needsQuotes(uiState);

    final List<Holding> holdings;
    final Map<String, Quote> quotes;
    if (needsQuotes) {
      final portfolioState = context.watch<PortfolioCubit>().state;
      holdings = portfolioState.holdings;
      quotes = portfolioState.quotes;
    } else {
      holdings = context.select<PortfolioCubit, List<Holding>>((c) => c.state.holdings);
      quotes = const {};
    }

    final visible = _filterAndSort(holdings, quotes, uiState);

    if (visible.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No holdings match your search/filter.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final holding = visible[index];
        return HoldingRow(key: ValueKey(holding.symbol), holding: holding);
      },
    );
  }

  List<Holding> _filterAndSort(
    List<Holding> holdings,
    Map<String, Quote> quotes,
    HoldingsUiState ui,
  ) {
    final query = ui.searchQuery.trim().toLowerCase();

    var list = holdings.where((h) {
      if (query.isNotEmpty &&
          !h.symbol.toLowerCase().contains(query) &&
          !h.companyName.toLowerCase().contains(query)) {
        return false;
      }
      return switch (ui.activeFilter) {
        SummaryFilter.all => true,
        SummaryFilter.profit => PortfolioCalculator.holdingPL(h, quotes) >= 0,
        SummaryFilter.loss => PortfolioCalculator.holdingPL(h, quotes) < 0,
        SummaryFilter.todaysGainers => (quotes[h.symbol]?.changePercent ?? 0) >= 0,
        SummaryFilter.todaysLosers => (quotes[h.symbol]?.changePercent ?? 0) < 0,
      };
    }).toList();

    int compare(Holding a, Holding b) {
      final result = switch (ui.sortColumn) {
        HoldingsSortColumn.symbol => a.symbol.compareTo(b.symbol),
        HoldingsSortColumn.quantity => a.quantity.compareTo(b.quantity),
        HoldingsSortColumn.avgBuyPrice => a.avgBuyPrice.compareTo(b.avgBuyPrice),
        HoldingsSortColumn.currentPrice =>
          PortfolioCalculator.currentPrice(a, quotes).compareTo(PortfolioCalculator.currentPrice(b, quotes)),
        HoldingsSortColumn.profitLoss =>
          PortfolioCalculator.holdingPL(a, quotes).compareTo(PortfolioCalculator.holdingPL(b, quotes)),
      };
      return ui.sortAscending ? result : -result;
    }

    list.sort(compare);
    return list;
  }
}
