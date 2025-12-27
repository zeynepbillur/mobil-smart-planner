import 'package:flutter/material.dart';
import 'package:rashad_frontend/models/category.dart';

class CategoryService {
  static final List<Category> _categories = [
    Category(
      id: '1',
      name: 'İş',
      color: Colors.blue,
      icon: Icons.business_center_rounded,
      description: 'İş ile ilgili görevler',
    ),
    Category(
      id: '2',
      name: 'Kişisel',
      color: Colors.green,
      icon: Icons.face_retouching_natural_rounded,
      description: 'Kişisel görevler',
    ),
    Category(
      id: '3',
      name: 'Acil',
      color: Colors.red,
      icon: Icons.electric_bolt_rounded,
      description: 'Acil görevler',
    ),
    Category(
      id: '4',
      name: 'Eğlence',
      color: Colors.purple,
      icon: Icons.auto_awesome_rounded,
      description: 'Eğlence ve hobi',
    ),
  ];

  Future<List<Category>> getCategories() async {
    return _categories;
  }

  static List<Category> get categories => _categories;

  static Category get defaultCategory => _categories.first;

  static Category getCategoryById(String? id) {
    return _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => _categories.first,
    );
  }
}
