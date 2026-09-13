import 'package:flutter_test/flutter_test.dart';
import 'package:investment_dashboard/features/portfolio/domain/entities/holding.dart';
import 'package:investment_dashboard/features/portfolio/domain/entities/quote.dart';
import 'package:investment_dashboard/features/portfolio/domain/portfolio_calculator.dart';

void main() {
  final holdings = [
    const Holding(symbol: 'AAPL', companyName: 'Apple', quantity: 10, avgBuyPrice: 100),
    const Holding(symbol: 'MSFT', companyName: 'Microsoft', quantity: 5, avgBuyPrice: 200),
  ];

  group('PortfolioCalculator', () {
    test('investedValue sums quantity * avgBuyPrice across holdings', () {
      expect(PortfolioCalculator.investedValue(holdings), 10 * 100 + 5 * 200);
    });

    test('currentValue falls back to avgBuyPrice when no quote exists yet', () {
      expect(PortfolioCalculator.currentValue(holdings, {}), PortfolioCalculator.investedValue(holdings));
    });

    test('currentValue uses live quote price once available', () {
      final quotes = {
        'AAPL': Quote(symbol: 'AAPL', price: 120, changePercent: 20, timestamp: DateTime.now()),
      };
      final expected = 10 * 120 + 5 * 200;
      expect(PortfolioCalculator.currentValue(holdings, quotes), expected);
    });

    test('profitLoss is derived from current minus invested, never stored', () {
      final quotes = {
        'AAPL': Quote(symbol: 'AAPL', price: 150, changePercent: 50, timestamp: DateTime.now()),
      };
      final invested = PortfolioCalculator.investedValue(holdings);
      final current = PortfolioCalculator.currentValue(holdings, quotes);
      expect(PortfolioCalculator.profitLoss(holdings, quotes), current - invested);
    });

    test('holdingPL is zero when price equals avg buy price', () {
      final quotes = {
        'AAPL': Quote(symbol: 'AAPL', price: 100, changePercent: 0, timestamp: DateTime.now()),
      };
      expect(PortfolioCalculator.holdingPL(holdings.first, quotes), 0);
    });
  });
}
