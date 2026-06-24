import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatAmount(double amount, [String symbol = '\$']) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(amount);
  }
}
