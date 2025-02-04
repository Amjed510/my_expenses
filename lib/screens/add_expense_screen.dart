import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/theme_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = '';
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      // تهيئة الفئات عند فتح الشاشة
      context.read<CategoriesProvider>().initialize(user.email);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<bool> _showBudgetWarningDialog(BuildContext context, double amount) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'تنبيه تجاوز الميزانية',
          style: TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'إضافة هذا المصروف سيتجاوز الميزانية الشهرية المحددة. هل تريد المتابعة؟',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'متابعة',
              style: TextStyle(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final expensesProvider = context.read<ExpensesProvider>();
        final amount = double.parse(_amountController.text);
        final currentBalance = await expensesProvider.getBalance();

        // التحقق من تجاوز الرصيد
        if (amount > currentBalance) {
          // عرض تنبيه للمستخدم
          if (!mounted) return;
          final shouldProceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('تنبيه'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المبلغ المدخل يتجاوز الرصيد الحالي!'),
                  const SizedBox(height: 8),
                  Text('الرصيد الحالي: ${currentBalance.toStringAsFixed(2)}'),
                  Text('المبلغ المطلوب: ${amount.toStringAsFixed(2)}'),
                  Text(
                    'المبلغ المتبقي: ${(currentBalance - amount).abs().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('متابعة على أي حال'),
                ),
              ],
            ),
          ) ?? false;

          if (!shouldProceed) {
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        // فحص الميزانية
        final budgetProvider = context.read<BudgetProvider>();
        final currentTotal = expensesProvider.getTotalExpensesForCurrentMonth();
        final budget = budgetProvider.currentBudget;
        
        if (budget != null && currentTotal + amount > budget.amount) {
          // عرض تنبيه تجاوز الميزانية
          final shouldContinue = await _showBudgetWarningDialog(context, amount);
          if (!shouldContinue) {
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        final expense = Expense(
          title: _titleController.text,
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
        );

        final success = await expensesProvider.addExpense(expense);

        if (!mounted) return;

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة المصروف بنجاح'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إضافة المصروف'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final categories = context.watch<CategoriesProvider>().categories;
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Center(child: Text('يجب تسجيل الدخول أولاً'));
    }

    if (categories.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'إضافة مصروف',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          iconTheme: IconThemeData(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فئات متاحة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إضافة فئات أولاً',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/categories');
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة فئة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.surfaceLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'إضافة مصروف',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان المصروف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان المصروف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'الرجاء إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(
                    _selectedCategory.isEmpty
                        ? Icons.category_outlined
                        : context.read<CategoriesProvider>().getCategoryIcon(_selectedCategory),
                    color: _selectedCategory.isEmpty
                        ? null
                        : context.read<CategoriesProvider>().getCategoryColor(_selectedCategory),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: category.color,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار الفئة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('التاريخ'),
                subtitle: Text(
                  '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.surfaceLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('حفظ المصروف'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
