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

static Future<void> initialize() async{
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([ExpenseSchema], directory: dir.path);
}

/*
*
* GETEERS
*
* */

List<Expense> get AllExpense => _allExpenses;

  /**
   *
   *
   * OPERATION
   */

//Create
Future<void> createNewExpense(Expense newExpense) async{
    await isar.writeTxn(() =>isar.expenses.put(newExpense));

   await readExpenses();
}
//Read
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);  // Add the list of expenses to _allExpenses

    notifyListeners();
  }

//Update
Future<void> updateExpense(int id, Expense updatedExpense) async{
    updatedExpense.id  = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
}

//Delete
Future<void> deleteExpense(int id) async{
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
}

/*
* Helpers
*
* */
}
