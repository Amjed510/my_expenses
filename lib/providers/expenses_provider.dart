import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/database_helper.dart';

class ExpensesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  double _totalExpenses = 0;
  double _currentBalance = 0;
  Map<String, double> _categoryTotals = {};

  List<Expense> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;
  double get currentBalance => _currentBalance;
  Map<String, double> get categoryTotals => _categoryTotals;

  // تحميل جميع المصروفات والرصيد
  Future<void> loadExpenses() async {
    _expenses = await _dbHelper.getAllExpenses();
    _currentBalance = await _dbHelper.getBalance();
    await _calculateTotals();
    notifyListeners();
  }

  // إضافة مبلغ للرصيد
  Future<void> addToBalance(double amount) async {
    await _dbHelper.addToBalance(amount);
    await loadExpenses();
  }

  // إضافة مصروف جديد
  Future<bool> addExpense(Expense expense) async {
    final success = await _dbHelper.insertExpense(expense);
    if (success) {
      await loadExpenses();
    }
    return success;
  }

  // تحديث مصروف
  Future<bool> updateExpense(Expense oldExpense, Expense newExpense) async {
    final success = await _dbHelper.updateExpense(oldExpense, newExpense);
    if (success) {
      await loadExpenses();
    }
    return success;
  }

  // حذف مصروف
  Future<bool> deleteExpense(int id) async {
    final success = await _dbHelper.deleteExpense(id);
    if (success) {
      await loadExpenses();
    }
    return success;
  }

  // حساب الإجماليات
  Future<void> _calculateTotals() async {
    _totalExpenses = await _dbHelper.getTotalExpenses();
    
    // حساب إجمالي كل فئة
    final categories = ['ايجار', 'تعليم', 'مواصلات', 'تسلية', 'طعام', 'اخرى'];
    _categoryTotals = {};
    
    for (var category in categories) {
      _categoryTotals[category] = await _dbHelper.getTotalExpensesByCategory(category);
    }
  }

  // الحصول على مصروفات فترة معينة
  Future<List<Expense>> getExpensesByPeriod(DateTime start, DateTime end) async {
    return await _dbHelper.getExpensesByPeriod(start, end);
  }

  // الحصول على إجمالي مصروفات فترة معينة
  Future<double> getTotalExpensesByPeriod(DateTime start, DateTime end) async {
    return await _dbHelper.getTotalExpensesByPeriod(start, end);
  }

  // الحصول على إجمالي المصروفات للشهر الحالي
  double getTotalExpensesForCurrentMonth() {
    final now = DateTime.now();
    return _expenses
        .where((expense) => 
          expense.date.month == now.month && 
          expense.date.year == now.year)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // الحصول على الرصيد الحالي
  Future<double> getBalance() async {
    return await _dbHelper.getBalance();
  }

  // الحصول على مصروفات اليوم
  Future<Map<String, double>> getDayExpenses() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    
    final expenses = await _dbHelper.getExpensesByPeriod(start, end);
    return _calculateCategoryTotals(expenses);
  }

  // الحصول على مصروفات آخر 30 يوم
  Future<Map<String, double>> getMonthExpenses() async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 30));
    
    final expenses = await _dbHelper.getExpensesByPeriod(start, end);
    return _calculateCategoryTotals(expenses);
  }

  // الحصول على مصروفات آخر سنة
  Future<Map<String, double>> getYearExpenses() async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 365));
    
    final expenses = await _dbHelper.getExpensesByPeriod(start, end);
    return _calculateCategoryTotals(expenses);
  }

  // حساب إجمالي كل فئة
  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }
}
