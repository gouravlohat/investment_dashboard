import 'dart:math';

import '../../domain/entities/portfolio_history_point.dart';
import '../models/holding_model.dart';

/// Mock "database" — no backend required per spec. Seed holdings match the
/// prod flavor's Finnhub-subscribable symbols so the real feed and the
/// portfolio line up.
class PortfolioLocalDataSource {
  List<HoldingModel> getSeedHoldings() => const [
        HoldingModel(symbol: 'AAPL', companyName: 'Apple Inc.', quantity: 25, avgBuyPrice: 168.40),
        HoldingModel(symbol: 'MSFT', companyName: 'Microsoft Corp.', quantity: 18, avgBuyPrice: 340.10),
        HoldingModel(symbol: 'GOOGL', companyName: 'Alphabet Inc.', quantity: 30, avgBuyPrice: 128.75),
        HoldingModel(symbol: 'AMZN', companyName: 'Amazon.com Inc.', quantity: 20, avgBuyPrice: 142.30),
        HoldingModel(symbol: 'TSLA', companyName: 'Tesla Inc.', quantity: 12, avgBuyPrice: 245.60),
        HoldingModel(symbol: 'META', companyName: 'Meta Platforms Inc.', quantity: 15, avgBuyPrice: 298.90),
        HoldingModel(symbol: 'NFLX', companyName: 'Netflix Inc.', quantity: 8, avgBuyPrice: 455.20),
        HoldingModel(symbol: 'NVDA', companyName: 'NVIDIA Corp.', quantity: 22, avgBuyPrice: 465.75),
      ];

  /// Deterministic 10-day portfolio value history, seeded random walk
  /// anchored at today's invested value so the chart looks plausible next
  /// to the live summary cards.
  List<PortfolioHistoryPoint> getHistory({required double anchorValue, int days = 10}) {
    final random = Random(42);
    final points = <PortfolioHistoryPoint>[];
    var value = anchorValue * 0.94;
    final now = DateTime.now();
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final drift = (random.nextDouble() - 0.45) * 0.02;
      value = value * (1 + drift);
      points.add(PortfolioHistoryPoint(date: date, value: value));
    }
    // Last point matches the live anchor so the chart connects seamlessly
    // with the "current value" summary card.
    points[points.length - 1] = PortfolioHistoryPoint(date: points.last.date, value: anchorValue);
    return points;
  }
}
