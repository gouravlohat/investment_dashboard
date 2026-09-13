import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/holdings_ui_cubit.dart';
import '../../cubit/holdings_ui_state.dart';

const _labels = {
  SummaryFilter.all: 'All',
  SummaryFilter.profit: 'In Profit',
  SummaryFilter.loss: 'In Loss',
  SummaryFilter.todaysGainers: "Today's Gainers",
  SummaryFilter.todaysLosers: "Today's Losers",
};

/// Filters the holdings table by total invested/profit/loss/today's change.
/// Lives entirely in [HoldingsUiCubit] — filtering never touches
/// [PortfolioCubit], so it can't be disturbed by a price tick.
class SummaryFilters extends StatelessWidget {
  const SummaryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.select<HoldingsUiCubit, SummaryFilter>((c) => c.state.activeFilter);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SummaryFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = SummaryFilter.values[index];
          final selected = filter == active;
          return ChoiceChip(
            label: Text(_labels[filter]!),
            selected: selected,
            onSelected: (_) => context.read<HoldingsUiCubit>().setFilter(filter),
          );
        },
      ),
    );
  }
}
