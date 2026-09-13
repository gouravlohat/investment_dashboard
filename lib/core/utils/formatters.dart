import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  static final _compactDate = DateFormat('EEE, d MMM yyyy');
  static final _time = DateFormat('HH:mm:ss');

  static String currency(double value) => _currency.format(value);

  static String percent(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String date(DateTime date) => _compactDate.format(date);

  static String time(DateTime date) => _time.format(date);
}
