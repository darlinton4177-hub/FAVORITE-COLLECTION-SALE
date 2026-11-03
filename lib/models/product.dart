class Product {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> images;
  final List<String> availableSizes;
  final List<String> availableColors;
  final bool isFeatured;
  final bool isFlashDeal;
  final String badge;
  final Map<String, String> specifications;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.originalPrice,
    this.rating = 4.8,
    this.reviewCount = 120,
    required this.stock,
    required this.images,
    this.availableSizes = const [],
    this.availableColors = const [],
    this.isFeatured = false,
    this.isFlashDeal = false,
    this.badge = '',
    this.specifications = const {},
  });

  int get discountPercentage {
    if (originalPrice <= price || originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  bool get inStock => stock > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'categoryId': categoryId,
    'price': price,
    'originalPrice': originalPrice,
    'rating': rating,
    'reviewCount': reviewCount,
    'stock': stock,
    'images': images,
    'availableSizes': availableSizes,
    'availableColors': availableColors,
    'isFeatured': isFeatured,
    'isFlashDeal': isFlashDeal,
    'badge': badge,
    'specifications': specifications,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice:
          (json['originalPrice'] as num?)?.toDouble() ??
          (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['reviewCount'] as int? ?? 50,
      stock: json['stock'] as int? ?? 10,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableSizes:
          (json['availableSizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableColors:
          (json['availableColors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isFlashDeal: json['isFlashDeal'] as bool? ?? false,
      badge: json['badge'] as String? ?? '',
      specifications:
          (json['specifications'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    int? stock,
    List<String>? images,
    List<String>? availableSizes,
    List<String>? availableColors,
    bool? isFeatured,
    bool? isFlashDeal,
    String? badge,
    Map<String, String>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashDeal: isFlashDeal ?? this.isFlashDeal,
      badge: badge ?? this.badge,
      specifications: specifications ?? this.specifications,
    );
  }
}
