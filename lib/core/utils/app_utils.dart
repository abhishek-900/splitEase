import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount, {String code = 'INR'}) {
    return NumberFormat.currency(
      locale: _locale(code),
      symbol: _symbol(code),
      decimalDigits: 2,
    ).format(amount);
  }

  static String _symbol(String code) =>
      const {
        'USD': '\$',
        'EUR': '€',
        'GBP': '£',
        'INR': '₹',
        'JPY': '¥',
        'CAD': 'CA\$',
        'AUD': 'A\$',
      }[code] ??
      code;

  static String _locale(String code) =>
      const {
        'USD': 'en_US',
        'EUR': 'de_DE',
        'GBP': 'en_GB',
        'INR': 'en_IN',
        'JPY': 'ja_JP',
        'CAD': 'en_CA',
        'AUD': 'en_AU',
      }[code] ??
      'en_US';
}

class AppDateUtils {
  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, y').format(date);
  }

  static String full(DateTime date) =>
      DateFormat('MMM d, y • h:mm a').format(date);

  static String short(DateTime date) => DateFormat('MMM d').format(date);
}

class Validators {
  static String? required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? amount(String? v) {
    if (v == null || v.isEmpty) return 'Amount is required';
    final d = double.tryParse(v);
    if (d == null) return 'Enter a valid number';
    if (d <= 0) return 'Amount must be > 0';
    return null;
  }

  static String? groupName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Group name is required';
    if (v.trim().length < 2) return 'Name is too short';
    if (v.trim().length > 50) return 'Name is too long';
    return null;
  }
}
