import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense_model.dart';

class ExpenseDatabase extends ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  static Future<void> initialize() async {
    // Simulate a delay for database initialization
    await Future.delayed(Duration(seconds: 2));
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
}