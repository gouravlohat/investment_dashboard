import '../../domain/entities/holding.dart';

/// Mock-seed representation of a holding. Kept as its own model (rather
/// than constructing [Holding] directly in the datasource) so a future
/// real backend integration only has to change this file's `fromJson`.
class HoldingModel {
  final String symbol;
  final String companyName;
  final double quantity;
  final double avgBuyPrice;

  const HoldingModel({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.avgBuyPrice,
  });

  Holding toEntity() => Holding(
        symbol: symbol,
        companyName: companyName,
        quantity: quantity,
        avgBuyPrice: avgBuyPrice,
      );
}
