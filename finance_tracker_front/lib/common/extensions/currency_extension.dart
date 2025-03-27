import 'package:intl/intl.dart';

extension CurrencyExtension on double {
  String toCurrency() {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  String toCurrencyWithSign() {
    final value = toCurrency();
    return this >= 0 ? '+ $value' : value;
  }
} 