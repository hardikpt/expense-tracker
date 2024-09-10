double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0;
}