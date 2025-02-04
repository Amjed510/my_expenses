import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import 'expense_card.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseList({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ExpenseCard(
            title: expense.title,
            amount: '${expense.amount.toStringAsFixed(2)} YR',
            date: expense.date.toString().split(' ')[0],
            category: expense.category,
          ),
        );
      },
    );
  }
}
