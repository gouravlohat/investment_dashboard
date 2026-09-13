import 'package:equatable/equatable.dart';

/// Transport-level price tick, decoupled from the domain [Quote] entity so
/// `core/` never depends on `features/`. The data layer maps this into a
/// domain `Quote`.
class RawQuoteTick extends Equatable {
  final String symbol;
  final double price;
  final double changePercent;
  final DateTime timestamp;

  const RawQuoteTick({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [symbol, price, changePercent, timestamp];
}
