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
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : '';

    final title = (json['title'] ?? '').toString();
    final subtitle = (json['subtitle'] ?? '').toString();
    final imagePath = (json['image_path'] ??
            json['imagePath'] ??
            json['image_url'] ??
            json['imageUrl'] ??
            json['image'] ??
            '')
        .toString();
    final targetCategoryId = (json['target_category_id'] ?? json['targetCategoryId'] ?? '').toString();
    final badge = (json['badge'] ?? 'OFFER').toString();

    return BannerItem(
      id: id,
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      targetCategoryId: targetCategoryId,
      badge: badge,
    );
  }
}
