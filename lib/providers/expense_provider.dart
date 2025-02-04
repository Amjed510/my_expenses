import 'package:flutter/foundation.dart';
import '../database/expense_dao.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseDao _expenseDao = ExpenseDao();
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await _expenseDao.getAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseDao.insertExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseDao.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _expenseDao.deleteExpense(id);
    await loadExpenses();
  }
}
