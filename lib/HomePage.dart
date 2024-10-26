import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/pages/add_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenseDatabase = Provider.of<ExpenseDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: ListView.builder(
        itemCount: expenseDatabase.expenses.length,
        itemBuilder: (context, index) {
          final expense = expenseDatabase.expenses[index];
          return ListTile(
            title: Text(expense.title),
            subtitle: Text('\$${expense.amount.toStringAsFixed(2)}'),
            trailing: Text(expense.date.toString()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}