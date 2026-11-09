class Coupon {
  final String code;
  final double discountPercent; // e.g., 20 for 20% off
  final double minOrderAmount;
  final String description;

  const Coupon({
    required this.code,
    required this.discountPercent,
    this.minOrderAmount = 0.0,
    required this.description,
  });

  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderAmount) return 0.0;
    return (subtotal * (discountPercent / 100));
  }
}

class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String targetCategoryId;
  final String badge;

  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.targetCategoryId = '',
    this.badge = 'LIMITED TIME',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'imagePath': imagePath,
    'targetCategoryId': targetCategoryId,
    'badge': badge,
  };

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: (json['subtitle'] ?? '') as String,
      imagePath: (json['image_path'] ?? json['imagePath'] ?? '') as String,
      targetCategoryId: (json['target_category_id'] ?? json['targetCategoryId'] ?? '') as String,
      badge: (json['badge'] ?? 'OFFER') as String,
    );
  }
}
