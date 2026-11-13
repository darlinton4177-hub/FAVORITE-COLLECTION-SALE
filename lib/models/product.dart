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
    // 1. Tolerant ID parsing (UUID or int or String)
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : '';

    // 2. Tolerant Title
    final title = (json['title'] ?? '').toString();

    // 3. Tolerant Description
    final description = (json['description'] ?? '').toString();

    // 4. Tolerant Category ID
    final rawCatId = json['category_id'] ?? json['categoryId'];
    final categoryId = rawCatId != null ? rawCatId.toString() : '';

    // 5. Tolerant numeric prices (num, String, or null)
    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    bool parseBool(dynamic val, [bool defaultVal = false]) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is String) {
        final lower = val.toLowerCase();
        return lower == 'true' || lower == '1';
      }
      if (val is num) return val != 0;
      return defaultVal;
    }

    final price = parseDouble(json['price'], 0.0);
    final rawOrig = json['original_price'] ?? json['originalPrice'];
    final originalPrice = rawOrig != null ? parseDouble(rawOrig, price) : price;
    final rating = parseDouble(json['rating'], 4.8);
    final reviewCount = parseInt(json['review_count'] ?? json['reviewCount'], 50);
    final stock = parseInt(json['stock'], 10);

    // 6. Tolerant images parsing (jsonb array, string, or null)
    List<String> images = [];
    final rawImages = json['images'] ??
        json['image_urls'] ??
        json['image_url'] ??
        json['image_path'] ??
        json['image'];
    if (rawImages is List) {
      images = rawImages
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
    } else if (rawImages is String && rawImages.trim().isNotEmpty) {
      images = [rawImages.trim()];
    }

    // 7. Tolerant sizes & colors
    List<String> sizes = [];
    final rawSizes = json['available_sizes'] ?? json['availableSizes'];
    if (rawSizes is List) {
      sizes = rawSizes.map((e) => e.toString()).toList();
    }

    List<String> colors = [];
    final rawColors = json['available_colors'] ?? json['availableColors'];
    if (rawColors is List) {
      colors = rawColors.map((e) => e.toString()).toList();
    }

    // 8. Booleans & badge
    final isFeatured = parseBool(json['is_featured'] ?? json['isFeatured'], false);
    final isFlashDeal = parseBool(json['is_flash_deal'] ?? json['isFlashDeal'], false);
    final badge = (json['badge'] ?? '').toString();

    // 9. Specifications (jsonb map or null)
    Map<String, String> specs = {};
    final rawSpecs = json['specifications'];
    if (rawSpecs is Map) {
      rawSpecs.forEach((k, v) {
        if (k != null && v != null) {
          specs[k.toString()] = v.toString();
        }
      });
    }

    return Product(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      reviewCount: reviewCount,
      stock: stock,
      images: images,
      availableSizes: sizes,
      availableColors: colors,
      isFeatured: isFeatured,
      isFlashDeal: isFlashDeal,
      badge: badge,
      specifications: specs,
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
