import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/widgets/chart.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

//When we have single return statement we could simply use arrow function.

class _ExpensesState extends State<Expenses> {
  final user = FirebaseAuth.instance.currentUser!.email;

  final List<Expense> _registeredExpense = [
    Expense(
        title: "Bike Service",
        amount: 3000,
        date: DateTime.now(),
        category: Category.travel),
    Expense(
        title: "Access Service",
        amount: 1500,
        date: DateTime.now(),
        category: Category.travel)
  ];

  Widget buildFirestoreExpenseList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data Here..."));
          }
          final expenses = snapshot.data!.docs
              .map((doc) => Expense.fromFireStore(
                  doc.data(), doc.id))
              .toList();

          return ExpensesList(
              expenses: expenses,
              onRemoveExpense: (expense) =>
                  _removeExpense(expense.id as Expense));
        });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
        useSafeArea: true, //won't take space of device camera or stuff
        isScrollControlled:
            true, //would take complete space, keyboard issues also solved
        context: context,
        builder: (ctx) => NewExpense(
              onAddExpense: _addExpense,
            ));
  }
  //its like a popup and allows for our content adding
  //allows for multiple widgets adding and
  //context : widgets meta information and also its position in widget tree

  void _addExpense(Expense expense) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .add(expense.toFirestore());

    // setState(() {
    //   _registeredExpense.add(expense);
    // });
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Logged Out Successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
    // Navigator.push(
    //     (context), MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _removeExpense(Expense expense) async {
    await FirebaseFirestore.instance.collection('expenses').doc().delete();

    final expenseIndex = _registeredExpense.indexOf(
        expense); //we need to get back with undo the event we removed so we can use indexof
    setState(() {
      _registeredExpense.remove(expense);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(
          child: Text('Expense Deleted'),
        ),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpense.insert(expenseIndex, expense);
                //After saving that expense with index now we can get those back
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    MediaQuery.of(context).size.height;

    //FirebaseFirestore.instance.collection("expenses").get()

    Widget mainContent = Center(
      child: Container(
        constraints: const BoxConstraints(
            maxWidth:
                600), //main content didn't have constraints so was taking max space hence kept it with limits
        child: const Text(
          'No Expense Yet, try Adding Some!!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
      ),
    );

    if (_registeredExpense.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpense,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Flutter Expense Tracker"),
        actions: [
          IconButton(
              onPressed: _openAddExpenseOverlay, icon: const Icon(Icons.add)),
          IconButton(
              onPressed: (() => signout()), icon: const Icon(Icons.login_rounded)),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Text(
                  'WELCOME, $user',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chart(expenses: _registeredExpense),
                const SizedBox(
                  height: 15,
                ),
                Expanded(child: buildFirestoreExpenseList()),
              ],
            )
          //const Text('The Chart'),
          // FutureBuilder(
          //     future:
          //         FirebaseFirestore.instance.collection("expenses").get(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //       if (!snapshot.hasData) {
          //         return const Text("No Data Here...");
          //       }

          //           return Expanded(child: mainContent);
          //         }),
          //     //const Text('C'),
          //   ],
          // )
          : Row(
              children: [
                Expanded(
                    child: Chart(
                        expenses:
                            _registeredExpense)), //without expanded it was width as double.infinity which wasn't working
                Expanded(child: buildFirestoreExpenseList()),
              ],
            ),
    );
  }
}
