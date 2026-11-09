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

  // Keep the lookup non-const: IconData.codePoint isn't usable in a const map
  // key on the Flutter SDK used by CI.
  static final Map<int, IconData> _knownIcons = {
    Icons.checkroom_rounded.codePoint: Icons.checkroom_rounded,
    Icons.dry_cleaning_rounded.codePoint: Icons.dry_cleaning_rounded,
    Icons.layers_rounded.codePoint: Icons.layers_rounded,
    Icons.filter_vintage_rounded.codePoint: Icons.filter_vintage_rounded,
    Icons.style_rounded.codePoint: Icons.style_rounded,
    Icons.all_inclusive_rounded.codePoint: Icons.all_inclusive_rounded,
    Icons.skateboarding_rounded.codePoint: Icons.skateboarding_rounded,
    Icons.watch_rounded.codePoint: Icons.watch_rounded,
    Icons.category_rounded.codePoint: Icons.category_rounded,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'iconCode': iconData.codePoint,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    final iconCode = (json['icon_code'] ?? json['iconCode']) as int?;
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      imagePath: (json['image_path'] ?? json['imagePath'] ?? '') as String,
      iconData: _knownIcons[iconCode] ?? Icons.category_rounded,
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
