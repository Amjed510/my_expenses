import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final Color color;
  final String userId;
  final IconData icon;
  final bool isDefault;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.userId,
    required this.icon,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'userId': userId,
      'icon': icon.codePoint,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      userId: map['userId'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      isDefault: (map['isDefault'] as int) == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    Color? color,
    String? userId,
    IconData? icon,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
