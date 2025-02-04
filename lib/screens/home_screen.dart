import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/expense_card.dart';
import '../providers/expenses_provider.dart';
import '../models/expense_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ExpensesProvider>(context, listen: false).loadExpenses());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showAddAmountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          title: Text(
            'إضافة مبلغ',
            style: AppStyles.titleStyle.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: AppStyles.getInputDecoration(
              label: 'المبلغ',
              hint: 'مثال: 1000',
              isDark: isDark,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppStyles.bodyStyle.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            ElevatedButton(
              style: AppStyles.primaryButtonStyle,
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  final provider =
                        Provider.of<ExpensesProvider>(context, listen: false);
                    provider
                        .addToBalance(double.parse(_amountController.text));
                    if (!mounted) return;
                    Navigator.pop(context);
                    _amountController.clear();
                }
              },
              child: Text(
                'إضافة',
                style: AppStyles.bodyStyle.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expenses = context.watch<ExpensesProvider>().expenses;
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black12 : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرصيد الحالي',
                          style: AppStyles.labelStyle.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${context.watch<ExpensesProvider>().currentBalance} ريال',
                          style: AppStyles.titleStyle.copyWith(
                            fontSize: 24,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: AppStyles.primaryButtonStyle,
                      onPressed: _showAddAmountDialog,
                      child: Text(
                        'إضافة رصيد',
                        style: AppStyles.bodyStyle.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد مصروفات',
                      style: AppStyles.bodyStyle.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ExpenseCard(
                          title: expense.title,
                          amount: expense.amount.toString(),
                          category: expense.category,
                          date: expense.date.toString(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          Icons.add,
          color: AppColors.textPrimaryDark,
        ),
      ),
    );
  }
}
