import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
  *
  * Set up
  *
  * */
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*
  *
  * GETTERS
  *
  * */
  List<Expense> get AllExpense => _allExpenses;

  /**
   *
   * OPERATION
   */

  //Create
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await readExpenses();
  }

  //Read
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _allExpenses.clear();
    _allExpenses
        .addAll(fetchedExpenses); // Add the list of expenses to _allExpenses
    notifyListeners();
  }

  //Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
  }

  //Delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
  }

  /*
   * Helpers
   */

  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpenses();
    Map<String, double> monthlyTotals = {};
    for (var expense in _allExpenses) {
     String yearMonth = '${expense.date.year}-${expense.date.month}';
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  Future<double> calculateCurrentMonthTotal() async {
    await readExpenses();
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpense = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

      double total =
        currentMonthExpense.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  // Get the start month of the earliest expense
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month; // If no expenses, return current month
    }

    // Sort by date to get the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.month;
  }

  // Get the start year of the earliest expense
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year; // If no expenses, return current year
    }

    // Sort by date to get the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.year;
  }
}
