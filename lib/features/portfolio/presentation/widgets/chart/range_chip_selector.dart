import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/chart_range_cubit.dart';

class RangeChipSelector extends StatelessWidget {
  const RangeChipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ChartRangeCubit>().state;

    return Wrap(
      spacing: 8,
      children: ChartRange.values.map((range) {
        return ChoiceChip(
          label: Text(range.label),
          selected: range == selected,
          onSelected: (_) => context.read<ChartRangeCubit>().select(range),
        );
      }).toList(),
    );
  }
}
