import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final List<String> categories;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
    );
  }
}
