import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();
//Inbuilt feature using for formatting date properly and efficiently

const uuid = Uuid();
//enum allows to define a category explicitly by us and we can use,
//custom type specifically

enum Category { food, travel, leisure, work, friends, personal }
//No = or "" coz we defined by ourselves as our need...

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
  Category.friends: Icons.dangerous,
  Category.personal: Icons.favorite,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  factory Expense.fromFireStore(Map<String, dynamic> data, String documentId) {
    return Expense(
        title: data['Title'] as String,
        amount: (data['Amount'] is num)
            ? (data['Amount'] as num).toDouble()
            : double.parse(data['Amount'] as String),
        date: (data['Date'] as Timestamp).toDate(),
        category: Category.values.firstWhere(
            (cat) => cat.name == (data['Category'] as String).toLowerCase(),
            orElse: () => Category.food));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Title': title,
      'Amount': amount,
      'Date': date,
      'Category': category.name,
    };
  }

  //Using it as a constructor for automatic adding and also we could use methods

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}

//Don't need id as required but instead we need it to increment automatic based on addition
// as a unique id

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

//getting a filtered way based on category, matching those first

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
