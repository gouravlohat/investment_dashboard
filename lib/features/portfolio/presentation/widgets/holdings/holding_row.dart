import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/entities/holding.dart';
import '../../../domain/entities/quote.dart';
import '../../../domain/portfolio_calculator.dart';
import '../../cubit/portfolio_cubit.dart';
import '../common/flash_on_change.dart';
import 'holding_row_editor.dart';

/// One holdings-table row. Static cells (symbol/company/qty/avg buy) come
/// straight from the `holding` this widget was built with, and this
/// widget itself never selects `PortfolioCubit`'s quotes — only the nested
/// [_LivePriceAndPl] cell does. A price tick therefore rebuilds that one
/// small cell, not this row, not the expansion editor, not the table.
class HoldingRow extends StatelessWidget {
  final Holding holding;

  const HoldingRow({required Key key, required this.holding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          title: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 420
                  ? _CompactRow(holding: holding)
                  : _WideRow(holding: holding);
            },
          ),
          children: [HoldingRowEditor(holding: holding)],
        ),
      ),
    );
  }
}

/// Full 5-column layout for tablet/wide phones.
class _WideRow extends StatelessWidget {
  final Holding holding;

  const _WideRow({required this.holding});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(holding.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                holding.companyName,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(holding.quantity.toStringAsFixed(0), textAlign: TextAlign.end)),
        Expanded(
          flex: 2,
          child: Text(Formatters.currency(holding.avgBuyPrice), textAlign: TextAlign.end),
        ),
        Expanded(flex: 2, child: _LivePriceCell(symbol: holding.symbol)),
        Expanded(flex: 2, child: _LivePlCell(holding: holding)),
      ],
    );
  }
}

/// Two-line stacked layout for narrow phones — same data, no horizontal
/// cramming/overflow at ~360-400dp widths.
class _CompactRow extends StatelessWidget {
  final Holding holding;

  const _CompactRow({required this.holding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(holding.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            _LivePriceCell(symbol: holding.symbol),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                '${holding.companyName} · ${holding.quantity.toStringAsFixed(0)} @ ${Formatters.currency(holding.avgBuyPrice)}',
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _LivePlCell(holding: holding),
          ],
        ),
      ],
    );
  }
}

class _LivePriceCell extends StatelessWidget {
  final String symbol;

  const _LivePriceCell({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final quote = context.select<PortfolioCubit, Quote?>((c) => c.state.quotes[symbol]);
    final theme = Theme.of(context);
    final semantic = theme.brightness == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light;
    return FlashOnChange<Quote?>(
      value: quote,
      flashColor: (quote?.isUp ?? true) ? semantic.gain : semantic.loss,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          quote == null ? '—' : Formatters.currency(quote.price),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}

class _LivePlCell extends StatelessWidget {
  final Holding holding;

  const _LivePlCell({required this.holding});

  @override
  Widget build(BuildContext context) {
    final quote = context.select<PortfolioCubit, Quote?>((c) => c.state.quotes[holding.symbol]);
    final quotes = quote == null ? <String, Quote>{} : {holding.symbol: quote};
    final pl = PortfolioCalculator.holdingPL(holding, quotes);
    final theme = Theme.of(context);
    final semantic = theme.brightness == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light;
    final color = pl >= 0 ? semantic.gain : semantic.loss;
    return FlashOnChange<Quote?>(
      value: quote,
      flashColor: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          Formatters.currency(pl),
          textAlign: TextAlign.end,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
