import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/database_helper.dart';

class CategoriesProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Category> _categories = [];
  
  List<Category> get categories => _categories;

  // تهيئة المزود عند بدء التطبيق
  Future<void> initializeApp() async {
    await initialize('default_user');
  }

  // الفئات الافتراضية
  static final List<Category> _defaultCategories = [
    Category(
      name: 'طعام',
      color: Colors.orange,
      userId: '',
      icon: Icons.restaurant,
      isDefault: true,
    ),
    Category(
      name: 'مواصلات',
      color: Colors.blue,
      userId: '',
      icon: Icons.directions_car,
      isDefault: true,
    ),
    Category(
      name: 'تسوق',
      color: Colors.purple,
      userId: '',
      icon: Icons.shopping_cart,
      isDefault: true,
    ),
    Category(
      name: 'ترفيه',
      color: Colors.pink,
      userId: '',
      icon: Icons.movie,
      isDefault: true,
    ),
    Category(
      name: 'صحة',
      color: Colors.red,
      userId: '',
      icon: Icons.local_hospital,
      isDefault: true,
    ),
    Category(
      name: 'تعليم',
      color: Colors.green,
      userId: '',
      icon: Icons.school,
      isDefault: true,
    ),
    Category(
      name: 'فواتير',
      color: Colors.indigo,
      userId: '',
      icon: Icons.receipt,
      isDefault: true,
    ),
    Category(
      name: 'أخرى',
      color: Colors.grey,
      userId: '',
      icon: Icons.more_horiz,
      isDefault: true,
    ),
  ];

  Future<void> initialize(String userId) async {
    // جلب الفئات من قاعدة البيانات
    _categories = await _dbHelper.getCategories(userId);

    // التحقق من وجود الفئات الافتراضية
    final defaultCategoryNames = _defaultCategories.map((c) => c.name).toSet();
    final existingDefaultCategories = _categories.where((c) => c.isDefault).map((c) => c.name).toSet();

    // إضافة الفئات الافتراضية المفقودة
    for (var category in _defaultCategories) {
      if (!existingDefaultCategories.contains(category.name)) {
        final newCategory = category.copyWith(userId: userId);
        await _dbHelper.insertCategory(newCategory);
      }
    }

    // إعادة تحميل جميع الفئات
    _categories = await _dbHelper.getCategories(userId);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    // التحقق من عدم وجود فئة بنفس الاسم
    if (_categories.any((cat) => cat.name == category.name)) {
      throw Exception('توجد فئة بنفس الاسم');
    }

    final id = await _dbHelper.insertCategory(category);
    _categories.add(category.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    if (category.isDefault) {
      throw Exception('لا يمكن تعديل الفئات الافتراضية');
    }

    // التحقق من عدم وجود فئة أخرى بنفس الاسم
    if (_categories.any((cat) => cat.id != category.id && cat.name == category.name)) {
      throw Exception('توجد فئة بنفس الاسم');
    }

    await _dbHelper.updateCategory(category);
    final index = _categories.indexWhere((cat) => cat.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(Category category) async {
    if (category.isDefault) {
      throw Exception('لا يمكن حذف الفئات الافتراضية');
    }

    // التحقق من عدم استخدام الفئة في أي مصروفات
    if (await _dbHelper.isCategoryUsed(category.id!)) {
      throw Exception('لا يمكن حذف الفئة لأنها مستخدمة في مصروفات');
    }

    await _dbHelper.deleteCategory(category.id!);
    _categories.removeWhere((cat) => cat.id == category.id);
    notifyListeners();
  }

  List<Category> searchCategories(String query) {
    return _categories
        .where((category) => 
          category.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Color getCategoryColor(String categoryName) {
    return _categories
        .firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => _defaultCategories.last,
        )
        .color;
  }

  IconData getCategoryIcon(String categoryName) {
    return _categories
        .firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => _defaultCategories.last,
        )
        .icon;
  }
}
