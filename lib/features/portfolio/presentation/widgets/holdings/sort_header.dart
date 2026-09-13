import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/holdings_ui_cubit.dart';
import '../../cubit/holdings_ui_state.dart';

const _columnLabels = {
  HoldingsSortColumn.symbol: 'Company',
  HoldingsSortColumn.quantity: 'Qty',
  HoldingsSortColumn.avgBuyPrice: 'Avg Buy',
  HoldingsSortColumn.currentPrice: 'Price',
  HoldingsSortColumn.profitLoss: 'P/L',
};

class SortHeader extends StatelessWidget {
  const SortHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HoldingsUiCubit>().state;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: HoldingsSortColumn.values.map((column) {
          final active = state.sortColumn == column;
          return Expanded(
            flex: column == HoldingsSortColumn.symbol ? 3 : 2,
            child: InkWell(
              onTap: () => context.read<HoldingsUiCubit>().setSort(column),
              child: Row(
                mainAxisAlignment:
                    column == HoldingsSortColumn.symbol ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _columnLabels[column]!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (active)
                    Icon(
                      state.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
