import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final IconData iconData;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.iconData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'iconCode': iconData.codePoint,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      iconData: json['iconCode'] != null
          ? IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons')
          : Icons.category_rounded,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    IconData? iconData,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      iconData: iconData ?? this.iconData,
    );
  }
}
