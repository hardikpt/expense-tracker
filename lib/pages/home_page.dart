import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_function.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [_cancelButton(), _createNewExpenseButton()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.AllExpense.length,
          itemBuilder: (context, index) {
            Expense individualExpense = value.AllExpense[index];
            return ListTile(
              title: Text(individualExpense.name),
              trailing: Text(individualExpense.amount.toString()),
            );
          },
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }
}
