import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key, required this.expenses, required this.onRemoveExpense});

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;
  //Column would directly create all items defined, but if 1000 so performance loss
  //not all would be together displayed

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) => Dismissible(
          key: ValueKey(expenses[index]),
          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
          ), //while swipe a red color as
          //   margin: EdgeInsets.symmetric(
          //       horizontal: Theme.of(context)
          //           .cardTheme
          //           .margin
          //           .horizontal), //Accessing the preset margin with theme
          // ),
          onDismissed: (direction) {
            onRemoveExpense(expenses[index]);
          },
          child: ExpenseItem(expense: expenses[index])),
      //itemBuilder would be creating stuff only when we pass to it not prior hence performance saved
    );
    // A special widget dismissible that allows for removal of data with just a swipe
  }
}
