import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/entities/holding.dart';
import '../../../domain/entities/quote.dart';
import '../../cubit/portfolio_cubit.dart';
import '../common/flash_on_change.dart';

/// Horizontal live ticker strip. Selects `state.holdings` (which keeps the
/// same List instance across price ticks — only `quotes` changes) so this
/// outer strip never rebuilds on a tick; each [_TickerChip] independently
/// selects its own symbol's quote so only the chip that actually moved
/// rebuilds.
class TickerStrip extends StatelessWidget {
  const TickerStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final holdings = context.select<PortfolioCubit, List<Holding>>((c) => c.state.holdings);

    if (holdings.isEmpty) {
      return const SizedBox(height: 42);
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: holdings.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _TickerChip(symbol: holdings[index].symbol),
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  final String symbol;

  const _TickerChip({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final quote = context.select<PortfolioCubit, Quote?>((c) => c.state.quotes[symbol]);
    final brightness = Theme.of(context).brightness;
    final semantic = brightness == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light;
    final color = quote == null ? semantic.neutral : (quote.isUp ? semantic.gain : semantic.loss);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: FlashOnChange<Quote?>(
        value: quote,
        flashColor: color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.1),
            ),
            const SizedBox(width: 6),
            Text(
              quote == null ? '—' : Formatters.currency(quote.price),
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
            if (quote != null) ...[
              const SizedBox(width: 3),
              Icon(
                quote.isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                size: 15,
                color: color,
              ),
              Text(
                Formatters.percent(quote.changePercent),
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
