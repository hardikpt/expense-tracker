import 'package:intl/intl.dart';

double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

String formatAmount(double amount){
  final format = NumberFormat.currency(locale: "en_US",symbol: "\₹", decimalDigits: 2);
  return format.format(amount);
}