import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenses.db');
    return await openDatabase(
      path,
      version: 1, // تحديث رقم الإصدار
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE balance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        userId TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // إنشاء رصيد افتتاحي بقيمة 0
    await db.insert('balance', {
      'amount': 0.0,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة جدول الفئات إذا كان الإصدار القديم أقل من 2
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color INTEGER NOT NULL,
          icon INTEGER NOT NULL,
          userId TEXT NOT NULL,
          isDefault INTEGER NOT NULL DEFAULT 0
        )
      ''');

      print("---------------------------- The categories Table Created ----------------------------");
    }
  }

  // إضافة مبلغ للرصيد
  Future<void> addToBalance(double amount) async {
    final db = await database;
    final currentBalance = await getBalance();
    await db.insert('balance', {
      'amount': currentBalance + amount,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // خصم مبلغ من الرصيد
  Future<bool> deductFromBalance(double amount) async {
    final db = await database;
    final currentBalance = await getBalance();

    // التحقق من كفاية الرصيد
    if (currentBalance < amount) {
      return false;
    }

    await db.insert('balance', {
      'amount': currentBalance - amount,
      'date': DateTime.now().toIso8601String(),
    });
    return true;
  }

  // الحصول على الرصيد الحالي
  Future<double> getBalance() async {
    final db = await database;
    final result = await db.query(
      'balance',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return 0.0;
    }

    return result.first['amount'] as double;
  }

  // إضافة مصروف جديد
  Future<bool> insertExpense(Expense expense) async {
    final db = await database;

    // محاولة خصم المبلغ من الرصيد
    final success = await deductFromBalance(expense.amount);
    if (!success) {
      return false;
    }

    await db.insert('expenses', expense.toMap());
    return true;
  }

  // الحصول على جميع المصروفات
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // الحصول على مصروفات فئة معينة
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // الحصول على إجمالي المصروفات
  Future<double> getTotalExpenses() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return result.first['total'] as double? ?? 0.0;
  }

  // الحصول على إجمالي المصروفات لفئة معينة
  Future<double> getTotalExpensesByCategory(String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE category = ?',
      [category],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  // تحديث مصروف
  Future<bool> updateExpense(Expense oldExpense, Expense newExpense) async {
    final db = await database;
    final double currentBalance = await getBalance();
    final double balanceDifference = newExpense.amount - oldExpense.amount;

    if (balanceDifference > 0 && balanceDifference > currentBalance) {
      return false;
    }

    await db.transaction((txn) async {
      await txn.update(
        'expenses',
        newExpense.toMap(),
        where: 'id = ?',
        whereArgs: [oldExpense.id],
      );

      if (balanceDifference != 0) {
        await txn.insert(
          'balance',
          {
            'amount': -balanceDifference,
            'date': DateTime.now().toIso8601String(),
          },
        );
      }
    });

    return true;
  }

  // حذف مصروف
  Future<bool> deleteExpense(int id) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      // الحصول على المصروف قبل حذفه
      final expenseResult = await txn.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (expenseResult.isEmpty) {
        return false;
      }

      final expense = expenseResult.first;
      final amount = expense['amount'] as double;

      // حذف المصروف
      final deleteResult = await txn.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deleteResult == 0) {
        return false;
      }

      // الحصول على الرصيد الحالي
      final balanceResult = await txn.query('balance', orderBy: 'id DESC', limit: 1);
      final currentBalance = balanceResult.isNotEmpty ? balanceResult.first['amount'] as double : 0.0;

      // إضافة المبلغ إلى الرصيد الحالي
      await txn.insert(
        'balance',
        {
          'amount': currentBalance + amount, // إضافة المبلغ المحذوف إلى الرصيد الحالي
          'date': DateTime.now().toIso8601String(),
        },
      );

      return true;
    });
  }

  // الحصول على مصروفات فترة زمنية معينة
  Future<List<Expense>> getExpensesByPeriod(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // الحصول على إجمالي المصروفات لفترة زمنية معينة
  Future<double> getTotalExpensesByPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  // طرق التعامل مع الفئات
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      {
        'name': category.name,
        'color': category.color.value,
        'icon': category.icon.codePoint,
        'userId': category.userId,
        'isDefault': category.isDefault ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId = ? OR isDefault = 1',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        color: Color(maps[i]['color'] as int),
        icon: IconData(
          maps[i]['icon'] as int,
          fontFamily: 'MaterialIcons',
          matchTextDirection: false,
        ),
        userId: maps[i]['userId'] as String,
        isDefault: maps[i]['isDefault'] == 1,
      );
    });
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      {
        'name': category.name,
        'color': category.color.value,
        'icon': category.icon.codePoint,
        'userId': category.userId,
        'isDefault': category.isDefault ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isCategoryUsed(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [categoryId.toString()],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
