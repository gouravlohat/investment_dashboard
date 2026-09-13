import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/portfolio_history_point.dart';
import '../../cubit/chart_range_cubit.dart';
import '../../cubit/portfolio_cubit.dart';

/// `state.history` is a stable list reference across price ticks (only
/// `quotes` changes on a tick), so this chart doesn't redraw on every
/// tick — only when the selected range changes.
class PerformanceChart extends StatelessWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.select<PortfolioCubit, List<PortfolioHistoryPoint>>((c) => c.state.history);
    final range = context.watch<ChartRangeCubit>().state;
    final theme = Theme.of(context);
    final semantic = theme.brightness == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light;

    if (history.isEmpty) {
      return const SizedBox(height: 220);
    }

    final visible = history.length <= range.days
        ? history
        : history.sublist(history.length - range.days);

    final isUp = visible.last.value >= visible.first.value;
    final lineColor = isUp ? semantic.gain : semantic.loss;

    final rawMin = visible.map((p) => p.value).reduce((a, b) => a < b ? a : b) * 0.98;
    final rawMax = visible.map((p) => p.value).reduce((a, b) => a > b ? a : b) * 1.02;
    // A rounded interval, with minY/maxY snapped to multiples of it, keeps
    // fl_chart's auto-generated tick labels from landing right next to the
    // chart's own top/bottom edge label and overlapping it.
    final yInterval = _niceInterval((rawMax - rawMin) / 4);
    final minY = (rawMin / yInterval).floor() * yInterval;
    final maxY = (rawMax / yInterval).ceil() * yInterval;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: yInterval,
                getTitlesWidget: (value, meta) => Text(
                  _compactCurrency(value),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (visible.length / 4).clamp(1, visible.length).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= visible.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM').format(visible[index].date),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final point = visible[spot.x.toInt()];
                return LineTooltipItem(
                  '${DateFormat('d MMM').format(point.date)}\n${_compactCurrency(point.value)}',
                  theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < visible.length; i++) FlSpot(i.toDouble(), visible[i].value),
              ],
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Rounds [rough] up to a "nice" 1/2/5 × 10^n step, so axis ticks land on
  /// round numbers (₹35.0K, ₹36.0K, …) instead of arbitrary fractions.
  double _niceInterval(double rough) {
    if (rough <= 0) return 1;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final residual = rough / magnitude;
    final niceResidual = residual > 5 ? 10.0 : (residual > 2 ? 5.0 : (residual > 1 ? 2.0 : 1.0));
    return niceResidual * magnitude;
  }

  String _compactCurrency(double value) {
    if (value.abs() >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (value.abs() >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
    return '₹${value.toStringAsFixed(0)}';
  }
}
