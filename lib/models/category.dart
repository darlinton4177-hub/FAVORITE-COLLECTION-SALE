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

  static const Map<String, IconData> categoryIconMap = {
    'clothing': Icons.checkroom_rounded,
    'jeans': Icons.dry_cleaning_rounded,
    'tops': Icons.layers_rounded,
    'dresses': Icons.filter_vintage_rounded,
    'trousers': Icons.style_rounded,
    'socks': Icons.all_inclusive_rounded,
    'footwear': Icons.skateboarding_rounded,
    'accessories': Icons.watch_rounded,
  };

  static IconData getIconForCategory(String id) {
    return categoryIconMap[id.toLowerCase()] ?? Icons.category_rounded;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    final catId = json['id'] as String;
    return Category(
      id: catId,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      iconData: getIconForCategory(catId),
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
