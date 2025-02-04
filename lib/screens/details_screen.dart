import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/category_model.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String _selectedPeriod = 'اليوم';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      
      expensesProvider.loadExpenses();
      if (user != null) {
        categoriesProvider.initialize(user.email);
      } else {
        categoriesProvider.initialize('default_user');
      }
    });
  }

  Widget _buildPeriodButton(String period) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedPeriod == period;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        foregroundColor: isSelected
            ? AppColors.textPrimaryDark
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => setState(() => _selectedPeriod = period),
      child: Text(
        period,
        style: AppStyles.bodyStyle.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, double amount, double percentage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.getBorderColor(isDark),
          width: 1,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                Text(
                  category.name,
                  style: AppStyles.titleStyle.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$amount ريال',
                  style: AppStyles.bodyStyle.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppStyles.bodyStyle.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>> _getExpensesByPeriod() {
    final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
    switch (_selectedPeriod) {
      case 'اليوم':
        return expensesProvider.getDayExpenses();
      case 'الشهر':
        return expensesProvider.getMonthExpenses();
      case 'السنة':
        return expensesProvider.getYearExpenses();
      default:
        return expensesProvider.getDayExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    
    // الحصول على جميع الفئات
    final categories = categoriesProvider.categories;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: FutureBuilder<Map<String, double>>(
        future: _getExpensesByPeriod(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final categoryTotals = snapshot.data ?? {};
          final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

          // ترتيب الفئات حسب المبلغ المصروف
          final sortedCategories = List<Category>.from(categories);
          sortedCategories.sort((a, b) {
            final aTotal = categoryTotals[a.name] ?? 0;
            final bTotal = categoryTotals[b.name] ?? 0;
            return bTotal.compareTo(aTotal);
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPeriodButton('اليوم'),
                    _buildPeriodButton('الشهر'),
                    _buildPeriodButton('السنة'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.getBorderColor(isDark),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'إجمالي المصروفات',
                                  style: AppStyles.labelStyle.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalExpenses.toStringAsFixed(2)} ريال',
                            style: AppStyles.titleStyle.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  'الرصيد المتبقي',
                                  style: AppStyles.labelStyle.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<double>(
                            future: expensesProvider.getBalance(),
                            builder: (context, snapshot) {
                              return Text(
                                '${snapshot.data?.toStringAsFixed(2) ?? '0.00'} ريال',
                                style: AppStyles.titleStyle.copyWith(
                                  color: Colors.green,
                                  fontSize: 20,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.pie_chart,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'المصروفات حسب الفئة',
                      style: AppStyles.titleStyle.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    final amount = categoryTotals[category.name] ?? 0.0;
                    final percentage = totalExpenses > 0
                        ? ((amount / totalExpenses) * 100)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCategoryCard(category, amount, percentage),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
