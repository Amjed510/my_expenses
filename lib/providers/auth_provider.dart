import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../providers/categories_provider.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromMap(json.decode(userJson));
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      final userIndex = users.indexWhere((user) => 
        user['email'] == email && user['password'] == password
      );

      if (userIndex != -1) {
        final userData = users[userIndex];
        _currentUser = User(
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          address: userData['address'] ?? '',
          joinDate: userData['joinDate'],
        );
        _isAuthenticated = true;
        await _saveUser();

        // تهيئة الفئات للمستخدم الجديد
        final categoriesProvider = CategoriesProvider();
        await categoriesProvider.initialize(_currentUser!.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      // التحقق من عدم وجود البريد الإلكتروني مسبقاً
      if (users.any((user) => user['email'] == email)) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = {
        'name': name,
        'email': email,
        'password': password,
        'phone': '',
        'address': '',
        'joinDate': DateTime.now().toString(),
      };

      users.add(newUser);
      await prefs.setString('users', json.encode(users));

      _currentUser = User(
        name: name,
        email: email,
        phone: '',
        address: '',
        joinDate: newUser['joinDate']!,
      );
      _isAuthenticated = true;
      await _saveUser();

      // تهيئة الفئات للمستخدم الجديد
      final categoriesProvider = CategoriesProvider();
      await categoriesProvider.initialize(_currentUser!.email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      final userIndex = users.indexWhere((user) => user['email'] == _currentUser!.email);
      if (userIndex != -1) {
        users[userIndex]['name'] = name ?? users[userIndex]['name'];
        users[userIndex]['phone'] = phone ?? users[userIndex]['phone'];
        users[userIndex]['address'] = address ?? users[userIndex]['address'];
        await prefs.setString('users', json.encode(users));

        _currentUser = User(
          name: name ?? _currentUser!.name,
          email: _currentUser!.email,
          phone: phone ?? _currentUser!.phone,
          address: address ?? _currentUser!.address,
          joinDate: _currentUser!.joinDate,
        );
        await _saveUser();
        notifyListeners();
      }
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      final userIndex = users.indexWhere((user) => 
        user['email'] == _currentUser!.email && user['password'] == currentPassword
      );

      if (userIndex != -1) {
        users[userIndex]['password'] = newPassword;
        await prefs.setString('users', json.encode(users));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_currentUser!.toMap()));
    }
  }
}
