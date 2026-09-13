import 'package:equatable/equatable.dart';

/// Raw, source-of-truth holding data. Deliberately does NOT carry any
/// computed field (current value, P/L, %) — those are always derived on
/// the fly by [PortfolioCalculator] from this + the latest [Quote].
class Holding extends Equatable {
  final String symbol;
  final String companyName;
  final double quantity;
  final double avgBuyPrice;

  /// User-set "target price alert" — the inline-editable field. Nullable
  /// until the user sets one.
  final double? targetPriceAlert;

  const Holding({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.avgBuyPrice,
    this.targetPriceAlert,
  });

  Holding copyWith({double? targetPriceAlert}) => Holding(
        symbol: symbol,
        companyName: companyName,
        quantity: quantity,
        avgBuyPrice: avgBuyPrice,
        targetPriceAlert: targetPriceAlert ?? this.targetPriceAlert,
      );

  /// copyWith that can also explicitly clear the alert (copyWith above
  /// can't distinguish "leave as-is" from "set to null").
  Holding withTargetPriceAlert(double? value) => Holding(
        symbol: symbol,
        companyName: companyName,
        quantity: quantity,
        avgBuyPrice: avgBuyPrice,
        targetPriceAlert: value,
      );

  @override
  List<Object?> get props =>
      [symbol, companyName, quantity, avgBuyPrice, targetPriceAlert];
}
