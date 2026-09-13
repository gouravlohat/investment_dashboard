import 'package:equatable/equatable.dart';

/// One day's total portfolio value, used by the performance chart.
class PortfolioHistoryPoint extends Equatable {
  final DateTime date;
  final double value;

  const PortfolioHistoryPoint({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}
