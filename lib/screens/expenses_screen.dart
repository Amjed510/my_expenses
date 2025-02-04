import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/expense_card.dart';
import '../providers/expenses_provider.dart';
import '../models/expense_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'طعام';
  final List<String> _categories = ['ايجار', 'تعليم', 'مواصلات', 'تسلية', 'طعام', 'اخرى'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<ExpensesProvider>(context, listen: false).loadExpenses()
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'إضافة مصروف',
          style: AppStyles.titleStyle.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: AppStyles.getInputDecoration(
                  label: 'العنوان',
                  hint: 'مثال: فاتورة الكهرباء',
                  isDark: isDark,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: AppStyles.getInputDecoration(
                  label: 'المبلغ',
                  hint: 'مثال: 100',
                  isDark: isDark,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: AppStyles.getInputDecoration(
                  label: 'الفئة',
                  isDark: isDark,
                ),
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: AppStyles.bodyStyle.copyWith(
                      color: AppColors.categoryColors[category],
                    ),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
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
            onPressed: () async {
              if (_titleController.text.isNotEmpty &&
                  _amountController.text.isNotEmpty) {
                try {
                  final expense = Expense(
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    category: _selectedCategory,
                    date: DateTime.now(),
                  );

                  await context.read<ExpensesProvider>().addExpense(expense);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _titleController.clear();
                  _amountController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'حدث خطأ أثناء إضافة المصروف',
                        style: AppStyles.errorStyle,
                      ),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
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
      ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي المصروفات',
                  style: AppStyles.titleStyle.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${context.watch<ExpensesProvider>().totalExpenses} ريال',
                  style: AppStyles.titleStyle.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 20,
                  ),
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
                      return Dismissible(
                        key: Key(expense.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: theme.colorScheme.error,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) async {
                          await context.read<ExpensesProvider>().deleteExpense(expense.id!);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ExpenseCard(
                            title: expense.title,
                            amount: expense.amount.toString(),
                            category: expense.category,
                            date: expense.date.toString(),
                          ),
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
