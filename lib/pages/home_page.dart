import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshData();
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void refreshData() {
    setState(() {
      _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
          .calculateMonthlyTotals();

      _calculateCurrentMonthTotal =
          Provider.of<ExpenseDatabase>(context, listen: false)
              .calculateCurrentMonthTotal();
    });
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [_cancelButton(), _createNewExpenseButton()],
      ),
    );
  }

  void openEditBox(Expense expense) {
    nameController.text = expense.name;
    amountController.text = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [_cancelButton(), _editExpenseButton(expense)],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [_cancelButton(), _deleteExpenseButton(expense)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      List<Expense> currentMonthExpress = value.AllExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: FutureBuilder<double>(
            future: _calculateCurrentMonthTotal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\₹${snapshot.data!.toStringAsFixed(2)}'),
                    Text(getCurrentMonthName()),
                  ],
                );
              } else {
                return Text("loading...");
              }
            },
          ),
          centerTitle: true, // Center the title if needed
          backgroundColor:
              Colors.white, // You can change the color to fit your theme
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(8.0), // Adds padding around the content
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder<Map<int, double>>(
                    future: _monthlyTotalFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading data"),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No data available"),
                        );
                      } else {
                        final monthlyTotals = snapshot.data!;
                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) => monthlyTotals[startMonth + index] ?? 0.0,
                        );
                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpress.length,
                    itemBuilder: (context, index) {
                      int reversdIndex = currentMonthExpress.length - 1 - index;

                      Expense individualExpense =
                          currentMonthExpress[reversdIndex];
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
          refreshData();
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());
          await context
              .read<ExpenseDatabase>()
              .updateExpense(expense.id, updatedExpense);

          refreshData();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _deleteExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(expense.id);
        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}
