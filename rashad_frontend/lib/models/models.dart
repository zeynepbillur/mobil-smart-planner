
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
  });
}

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  String status;
  final String userId;
  late final String categoryId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.userId,
    required this.categoryId,
  });
}

class Category {
  final String id;
  final String name;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });
}

class Program {
  final String id;
  final String name;
  final String description;
  final String code;
  final List<Task> tasks;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.tasks,
  });
}

// ================= MOCK DATA =================
List<User> mockUsers = [
  User(id: '1', name: 'Ali Yılmaz', email: 'ali@test.com', role: 'user'),
  User(id: '2', name: 'Admin User', email: 'admin@test.com', role: 'admin'),
  User(id: '3', name: 'Ayşe Demir', email: 'ayse@test.com', role: 'user'),
];

List<Task> mockTasks = [
  Task(
    id: '1',
    title: 'Flutter Uygulaması Geliştir',
    description: 'Mock data ile çalışan frontend uygulaması yap',
    dueDate: DateTime.now(),
    status: 'pending',
    userId: '1',
    categoryId: '1',
  ),
  Task(
    id: '2',
    title: 'Toplantıya Katıl',
    description: 'Saat 14:00\'da proje toplantısı',
    dueDate: DateTime.now().add(Duration(days: 1)),
    status: 'completed',
    userId: '1',
    categoryId: '2',
  ),
  Task(
    id: '3',
    title: 'Raporu Tamamla',
    description: 'Aylık raporu gönder',
    dueDate: DateTime.now().add(Duration(days: -1)),
    status: 'pending',
    userId: '1',
    categoryId: '3',
  ),
  Task(
    id: '4',
    title: 'Admin Task 1',
    description: 'Admin için örnek görev',
    dueDate: DateTime.now(),
    status: 'pending',
    userId: '2',
    categoryId: '1',
  ),
];

List<Category> mockCategories = [
  Category(id: '1', name: 'İş', color: Colors.blue),
  Category(id: '2', name: 'Kişisel', color: Colors.green),
  Category(id: '3', name: 'Acil', color: Colors.red),
  Category(id: '4', name: 'Eğlence', color: Colors.purple),
];

List<Program> mockPrograms = [
  Program(
    id: '1',
    name: 'Yazılım Geliştirme Programı',
    description: 'Flutter ve backend geliştirme programı',
    code: 'ABC123',
    tasks: mockTasks.sublist(0, 2),
  ),
  Program(
    id: '2',
    name: 'Yönetici Programı',
    description: 'Yöneticiler için özel program',
    code: 'ADMIN99',
    tasks: [mockTasks[3]],
  ),
];