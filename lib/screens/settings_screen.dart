import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: AppStyles.bodyStyle.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.labelStyle.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: AppStyles.titleStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'المظهر',
                style: AppStyles.titleStyle.copyWith(
                  fontSize: 20,
                ),
              ),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return _buildSettingItem(
                  title: 'الوضع الداكن',
                  subtitle: 'تغيير مظهر التطبيق بين الوضع الفاتح والداكن',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: AppColors.primaryLight,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'الإشعارات',
                style: AppStyles.titleStyle.copyWith(
                  fontSize: 20,
                ),
              ),
            ),
            _buildSettingItem(
              title: 'إشعارات المصروفات',
              subtitle: 'تلقي إشعارات عند إضافة أو تعديل المصروفات',
              trailing: Switch(
                value: true, // TODO: Implement notifications settings
                onChanged: (value) {},
                activeColor: AppColors.primaryLight,
              ),
            ),
            _buildSettingItem(
              title: 'التذكير اليومي',
              subtitle: 'تلقي تذكير يومي لإضافة المصروفات',
              trailing: Switch(
                value: false, // TODO: Implement notifications settings
                onChanged: (value) {},
                activeColor: AppColors.primaryLight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'العملة',
                style: AppStyles.titleStyle.copyWith(
                  fontSize: 20,
                ),
              ),
            ),
            _buildSettingItem(
              title: 'العملة الافتراضية',
              subtitle: 'ريال يمني',
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement currency selection
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'التطبيق',
                style: AppStyles.titleStyle.copyWith(
                  fontSize: 20,
                ),
              ),
            ),
            _buildSettingItem(
              title: 'حول التطبيق',
              subtitle: 'معلومات عن التطبيق والإصدار',
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            _buildSettingItem(
              title: 'تقييم التطبيق',
              subtitle: 'قم بتقييم التطبيق على متجر التطبيقات',
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement app rating
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
