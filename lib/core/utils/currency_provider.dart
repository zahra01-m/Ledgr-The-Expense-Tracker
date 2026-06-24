import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({required this.code, required this.name, required this.symbol});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

const List<Currency> supportedCurrencies = [
  Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  Currency(code: 'EUR', name: 'Euro', symbol: '€'),
  Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
  Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs.'),
];

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(supportedCurrencies[0]) {
    _load();
  }

  static const _key = 'app_currency_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      state = supportedCurrencies.firstWhere(
        (c) => c.code == code,
        orElse: () => supportedCurrencies[0],
      );
    }
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency.code);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});