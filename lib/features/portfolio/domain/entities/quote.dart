import 'package:equatable/equatable.dart';

/// Latest live price for a symbol. Equatable value semantics are load
/// bearing: `context.select` only rebuilds a widget when the selected
/// `Quote` is unequal to the previous one, which is how we avoid
/// whole-table rebuilds on every tick.
class Quote extends Equatable {
  final String symbol;
  final double price;

  /// Change % since session start (simulated feed) or since first trade
  /// observed this session (Finnhub feed) — see README for why.
  final double changePercent;
  final DateTime timestamp;

  const Quote({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.timestamp,
  });

  bool get isUp => changePercent >= 0;

  @override
  List<Object?> get props => [symbol, price, changePercent, timestamp];
}
