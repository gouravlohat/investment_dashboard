import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/breakpoints.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../widgets/chart/performance_chart.dart';
import '../widgets/chart/range_chip_selector.dart';
import '../widgets/header/app_header.dart';
import '../widgets/holdings/holdings_search_bar.dart';
import '../widgets/holdings/holdings_table.dart';
import '../widgets/holdings/sort_header.dart';
import '../widgets/summary/summary_cards_row.dart';
import '../widgets/summary/summary_filters.dart';

/// Composes the whole screen from independent widgets that each subscribe
/// only to the cubit slice they need — this page itself never watches
/// `PortfolioCubit` broadly (only a `status`-scoped `buildWhen`), so it
/// never rebuilds on a price tick; that's delegated entirely to the leaf
/// widgets (ticker chips, price/P&L cells, summary cards).
class DashboardPage extends StatelessWidget {
  final AppConfig config;

  const DashboardPage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    return Scaffold(
      appBar: AppHeader(config: config),
      body: BlocBuilder<PortfolioCubit, PortfolioState>(
        buildWhen: (prev, curr) => prev.status != curr.status,
        builder: (context, state) {
          if (state.status == PortfolioStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: 16,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SummaryCardsRow(),
                      SizedBox(height: 14),
                      SummaryFilters(),
                      SizedBox(height: 24),
                      _PerformanceChartCard(),
                      SizedBox(height: 24),
                      _HoldingsSection(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PerformanceChartCard extends StatelessWidget {
  const _PerformanceChartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Performance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const RangeChipSelector(),
            const SizedBox(height: 16),
            const PerformanceChart(),
          ],
        ),
      ),
    );
  }
}

class _HoldingsSection extends StatelessWidget {
  const _HoldingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Holdings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const HoldingsSearchBar(),
        const SizedBox(height: 12),
        const SortHeader(),
        const Divider(height: 1),
        const SizedBox(height: 4),
        const HoldingsTable(),
      ],
    );
  }
}
