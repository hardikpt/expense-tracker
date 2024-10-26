import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpensePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final expense = Expense(
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      date: DateTime.now(),
                    );
                    Provider.of<ExpenseDatabase>(context, listen: false)
                        .addExpense(expense);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}