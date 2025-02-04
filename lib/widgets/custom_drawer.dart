import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final currentUser = context.read<AuthProvider>().currentUser;

    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Icon(
                Icons.person,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 32,
              ),
            ),
            accountName: Text(
              currentUser?.name ?? 'مستخدم',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              currentUser?.email ?? '',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'الرئيسية',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'الملف الشخصي',
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.add_circle,
                  title: 'إضافة مصروف',
                  onTap: () {
                    Navigator.pushNamed(context, '/add-expense');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'الإحصائيات',
                  onTap: () {
                    Navigator.pushNamed(context, '/statistics');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  title: 'الميزانية',
                  onTap: () {
                    Navigator.pushNamed(context, '/budget');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.category,
                  title: 'إدارة الفئات',
                  onTap: () {
                    Navigator.pushNamed(context, '/categories');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'حول التطبيق',
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                  isDark: isDark,
                ),

                 _buildDrawerItem(
                  icon: Icons.lock,
                  title: 'تغيير كلمة السر',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                  isDark: isDark,
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  onTap: () async {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      onTap: onTap,
      hoverColor: isDark ? AppColors.primaryDark.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1),
    );
  }
}
