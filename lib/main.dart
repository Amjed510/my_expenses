import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'utils/create_icon.dart';
import 'providers/expenses_provider.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpensesProvider(),
      child: const MyExpensesApp(),
    ),
  );
}
