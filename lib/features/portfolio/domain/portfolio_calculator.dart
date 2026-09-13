import 'entities/holding.dart';
import 'entities/quote.dart';

/// Pure functions only — no state. Every summary number the UI shows is
/// computed here, on demand, from raw holdings + the latest quotes map.
/// Nothing here is ever cached as a separate field, so it can never drift
/// out of sync with the source data (see README for the rationale).
class PortfolioCalculator {
  PortfolioCalculator._();

  static double investedValue(List<Holding> holdings) =>
      holdings.fold(0, (sum, h) => sum + h.quantity * h.avgBuyPrice);

  static double currentPrice(Holding holding, Map<String, Quote> quotes) =>
      quotes[holding.symbol]?.price ?? holding.avgBuyPrice;

  static double currentValue(List<Holding> holdings, Map<String, Quote> quotes) =>
      holdings.fold(
        0,
        (sum, h) => sum + h.quantity * currentPrice(h, quotes),
      );

  static double profitLoss(List<Holding> holdings, Map<String, Quote> quotes) =>
      currentValue(holdings, quotes) - investedValue(holdings);

  static double profitLossPercent(List<Holding> holdings, Map<String, Quote> quotes) {
    final invested = investedValue(holdings);
    if (invested == 0) return 0;
    return (profitLoss(holdings, quotes) / invested) * 100;
  }

  /// Sum of each holding's (price * qty * changePercent/100) — the rupee
  /// amount the portfolio moved today based on each symbol's live change%.
  static double todaysChange(List<Holding> holdings, Map<String, Quote> quotes) {
    return holdings.fold(0, (sum, h) {
      final quote = quotes[h.symbol];
      if (quote == null) return sum;
      final priorPrice = quote.changePercent == -100
          ? 0
          : quote.price / (1 + quote.changePercent / 100);
      return sum + (quote.price - priorPrice) * h.quantity;
    });
  }

  static double todaysChangePercent(List<Holding> holdings, Map<String, Quote> quotes) {
    final current = currentValue(holdings, quotes);
    final change = todaysChange(holdings, quotes);
    final priorValue = current - change;
    if (priorValue == 0) return 0;
    return (change / priorValue) * 100;
  }

  static double holdingPL(Holding holding, Map<String, Quote> quotes) =>
      (currentPrice(holding, quotes) - holding.avgBuyPrice) * holding.quantity;

  static double holdingPLPercent(Holding holding, Map<String, Quote> quotes) {
    if (holding.avgBuyPrice == 0) return 0;
    return ((currentPrice(holding, quotes) - holding.avgBuyPrice) / holding.avgBuyPrice) * 100;
  }
}
