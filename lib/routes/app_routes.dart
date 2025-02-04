import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/details_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/change_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';
  static const String details = '/details';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        expenses: (context) => const ExpensesScreen(),
        addExpense: (context) => const AddExpenseScreen(),
        details: (context) => const DetailsScreen(),
        settings: (context) => const SettingsScreen(),
        changePassword: (context) => const ChangePasswordScreen(),
      };
}
