import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData? icon;
  final String? description;

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] is Map ? json['_id']['\$oid'] : (json['_id'] ?? json['id']),
      name: json['name'],
      color: json['color'] is String 
          ? Color(int.parse(json['color'].replaceAll('#', '0xff')))
          : Color(json['color'] ?? 0xFF000000),
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {'\$oid': id},
      'name': name,
      'color': '#${color.value.toRadixString(16).substring(2)}', // Store as hex string
      'icon': icon?.codePoint,
      'description': description,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }
}
