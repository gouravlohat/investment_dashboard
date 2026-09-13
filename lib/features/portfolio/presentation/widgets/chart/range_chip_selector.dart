import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/chart_range_cubit.dart';

class RangeChipSelector extends StatelessWidget {
  const RangeChipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ChartRangeCubit>().state;
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      children: ChartRange.values.map((range) {
        final isSelected = range == selected;
        return ChoiceChip(
          label: Text(range.label),
          selected: isSelected,
          showCheckmark: false,
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
          onSelected: (_) => context.read<ChartRangeCubit>().select(range),
        );
      }).toList(),
    );
  }
}
