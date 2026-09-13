import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/portfolio_calculator.dart';
import '../../cubit/portfolio_cubit.dart';
import 'summary_card.dart';

/// These numbers are computed here, on every rebuild, straight from raw
/// holdings + latest quotes — never read from a pre-computed field. That's
/// intentional: it's the only way P/L/%/today's-change can't drift out of
/// sync with the source data (see README).
class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PortfolioCubit>().state;
    final theme = Theme.of(context);
    final semantic = theme.brightness == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light;

    final invested = PortfolioCalculator.investedValue(state.holdings);
    final current = PortfolioCalculator.currentValue(state.holdings, state.quotes);
    final pl = PortfolioCalculator.profitLoss(state.holdings, state.quotes);
    final plPercent = PortfolioCalculator.profitLossPercent(state.holdings, state.quotes);
    final todaysChange = PortfolioCalculator.todaysChange(state.holdings, state.quotes);
    final todaysChangePercent = PortfolioCalculator.todaysChangePercent(state.holdings, state.quotes);

    final plColor = pl >= 0 ? semantic.gain : semantic.loss;
    final todaysColor = todaysChange >= 0 ? semantic.gain : semantic.loss;

    final columns = Breakpoints.summaryColumns(context);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // A fixed row height (rather than an aspect ratio) keeps every card
      // tall enough for its content regardless of how narrow the column
      // gets — aspect ratio shrinks height along with width, which is
      // exactly wrong for text that doesn't get any smaller.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 128,
      ),
      children: [
        SummaryCard(
          title: 'Total Invested',
          value: Formatters.currency(invested),
          icon: Icons.savings_outlined,
        ),
        SummaryCard(
          title: 'Current Value',
          value: Formatters.currency(current),
          icon: Icons.account_balance_wallet_outlined,
        ),
        SummaryCard(
          title: 'Total P/L',
          value: Formatters.currency(pl),
          subtitle: Formatters.percent(plPercent),
          valueColor: plColor,
          icon: Icons.trending_up,
        ),
        SummaryCard(
          title: "Today's Change",
          value: Formatters.currency(todaysChange),
          subtitle: Formatters.percent(todaysChangePercent),
          valueColor: todaysColor,
          icon: Icons.show_chart,
        ),
      ],
    );
  }
}
