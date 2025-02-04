import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Budget {
  final double amount;
  final DateTime startDate;

  Budget({
    required this.amount,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      amount: map['amount'] as double,
      startDate: DateTime.parse(map['startDate'] as String),
    );
  }
}

class BudgetProvider extends ChangeNotifier {
  Budget? _currentBudget;
  Budget? get currentBudget => _currentBudget;

  BudgetProvider() {
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final amount = prefs.getDouble('budget_amount');
    final startDateString = prefs.getString('budget_start_date');

    if (amount != null && startDateString != null) {
      final startDate = DateTime.parse(startDateString);
      // التحقق من أن الميزانية للشهر الحالي
      final now = DateTime.now();
      if (startDate.month == now.month && startDate.year == now.year) {
        _currentBudget = Budget(
          amount: amount,
          startDate: startDate,
        );
        notifyListeners();
      }
    }
  }

  Future<void> setBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    // تعيين تاريخ البداية إلى أول يوم في الشهر الحالي
    final startDate = DateTime(now.year, now.month, 1);

    await prefs.setDouble('budget_amount', amount);
    await prefs.setString('budget_start_date', startDate.toIso8601String());

    _currentBudget = Budget(
      amount: amount,
      startDate: startDate,
    );
    notifyListeners();
  }

  Future<void> clearBudget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('budget_amount');
    await prefs.remove('budget_start_date');
    _currentBudget = null;
    notifyListeners();
  }

  double getBudgetProgress(double totalExpenses) {
    if (_currentBudget == null || _currentBudget!.amount == 0) return 0;
    return (totalExpenses / _currentBudget!.amount).clamp(0.0, 1.0);
  }

  bool isOverBudget(double totalExpenses) {
    if (_currentBudget == null) return false;
    return totalExpenses > _currentBudget!.amount;
  }

  String getRemainingBudget(double totalExpenses) {
    if (_currentBudget == null) return '0';
    return (_currentBudget!.amount - totalExpenses).toStringAsFixed(2);
  }

  // التحقق من صلاحية الميزانية للشهر الحالي
  Future<void> validateBudget() async {
    if (_currentBudget == null) return;

    final now = DateTime.now();
    if (_currentBudget!.startDate.month != now.month || 
        _currentBudget!.startDate.year != now.year) {
      await clearBudget();
    }
  }
}
