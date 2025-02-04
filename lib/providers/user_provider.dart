import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromMap(json.decode(userJson));
      notifyListeners();
    } else {
      // Default user data
      _user = User(
        name: 'أمجد الحميدي',
        email: 'amjed@example.com',
        phone: '+967 7300 42 992',
        address: 'صنعاء، اليمن',
        joinDate: '1 يناير 2024',
      );
      await _saveUser();
    }
  }

  Future<void> _saveUser() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toMap()));
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _saveUser();
  }
}
