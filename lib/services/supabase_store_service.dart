import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/banner_item.dart';
import '../models/order.dart';

/// Which backend the app is currently reading from.
enum DataSource { live, cached, offline, error }

/// Result of a single fetch: the parsed rows, the source, and any error.
class FetchResult<T> {
  final List<T> rows;
  final DataSource source;
  final String? error;
  const FetchResult(this.rows, this.source, {this.error});
}

class SupabaseStoreService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get _isClientReady => _client != null;

  // ─── READ: Categories ───────────────────────────────────────────────────────

  static Future<FetchResult<Category>> fetchCategories() async {
    if (!_isClientReady) {
      return const FetchResult([], DataSource.offline, error: 'Supabase client not initialised');
    }
    try {
      final response = await _client!
          .from('categories')
          .select()
          .order('name');
      final rows = _parseRows<Category>(
        response as List<dynamic>,
        (json) => Category.fromJson(json),
        table: 'categories',
      );
      return FetchResult(rows, DataSource.live);
    } catch (e) {
      final msg = 'fetchCategories: $e';
      debugPrint('[SupabaseStore] $msg');
      return FetchResult(const [], DataSource.error, error: msg);
    }
  }

  // ─── READ: Products ──────────────────────────────────────────────────────────

  static Future<FetchResult<Product>> fetchProducts() async {
    if (!_isClientReady) {
      return const FetchResult([], DataSource.offline, error: 'Supabase client not initialised');
    }
    try {
      final response = await _client!
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final rows = _parseRows<Product>(
        response as List<dynamic>,
        (json) => Product.fromJson(json),
        table: 'products',
      );
      return FetchResult(rows, DataSource.live);
    } catch (e) {
      final msg = 'fetchProducts: $e';
      debugPrint('[SupabaseStore] $msg');
      return FetchResult(const [], DataSource.error, error: msg);
    }
  }

  // ─── READ: Banners ───────────────────────────────────────────────────────────

  static Future<FetchResult<BannerItem>> fetchBanners() async {
    if (!_isClientReady) {
      return const FetchResult([], DataSource.offline, error: 'Supabase client not initialised');
    }
    try {
      final response = await _client!
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: true);
      final rows = _parseRows<BannerItem>(
        response as List<dynamic>,
        (json) => BannerItem.fromJson(json),
        table: 'banners',
      );
      return FetchResult(rows, DataSource.live);
    } catch (e) {
      final msg = 'fetchBanners: $e';
      debugPrint('[SupabaseStore] $msg');
      return FetchResult(const [], DataSource.error, error: msg);
    }
  }

  // ─── WRITE: Products ─────────────────────────────────────────────────────────

  static Future<void> insertProduct(Product product) async {
    await _client!.from('products').insert(_productToSupabaseJson(product));
  }

  static Future<void> updateProduct(Product product) async {
    await _client!
        .from('products')
        .update(_productToSupabaseJson(product))
        .eq('id', product.id);
  }

  static Future<void> deleteProduct(String productId) async {
    await _client!.from('products').delete().eq('id', productId);
  }

  // ─── WRITE: Categories ───────────────────────────────────────────────────────

  static Future<void> insertCategory(Category category) async {
    await _client!.from('categories').insert(_categoryToSupabaseJson(category));
  }

  static Future<void> updateCategory(Category category) async {
    await _client!
        .from('categories')
        .update(_categoryToSupabaseJson(category))
        .eq('id', category.id);
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _client!.from('categories').delete().eq('id', categoryId);
  }

  // ─── WRITE: Banners ──────────────────────────────────────────────────────────

  static Future<void> insertBanner(BannerItem banner) async {
    await _client!.from('banners').insert(_bannerToSupabaseJson(banner));
  }

  static Future<void> updateBanner(BannerItem banner) async {
    await _client!
        .from('banners')
        .update(_bannerToSupabaseJson(banner))
        .eq('id', banner.id);
  }

  static Future<void> deleteBanner(String bannerId) async {
    await _client!.from('banners').delete().eq('id', bannerId);
  }

  // ─── WRITE: Orders ───────────────────────────────────────────────────────────

  static Future<String?> insertOrder(Order order) async {
    final userId = _client?.auth.currentUser?.id;
    final data = {
      'id': order.id,
      'user_id': userId,
      'customer_name': order.customerName,
      'customer_email': order.customerEmail,
      'shipping_address': order.shippingAddress,
      'payment_method': order.paymentMethod,
      'applied_coupon': order.appliedCoupon,
      'subtotal': order.subtotal,
      'discount': order.discount,
      'shipping_fee': order.shippingFee,
      'tax': order.tax,
      'total': order.total,
      'status': order.status.name,
      'items': order.items.map((e) => e.toJson()).toList(),
    };
    try {
      await _client!.from('orders').insert(data);
      return null; // success
    } catch (e) {
      debugPrint('[SupabaseStore] insertOrder error: $e');
      return e.toString();
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await _client!
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }

  static Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final response = await _client!
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  // ─── WRITE: Image Upload ─────────────────────────────────────────────────────

  /// Uploads a local file to Supabase Storage and returns the public URL.
  static Future<String?> uploadImage(String localPath, String bucket) async {
    try {
      final file = File(localPath);
      final filename = 'img_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      await _client!.storage.from(bucket).upload(filename, file);
      final publicUrl = _client!.storage.from(bucket).getPublicUrl(filename);
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseStore] uploadImage error: $e');
      return null;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Parse each row individually; skip bad rows, log the offending row + error.
  static List<T> _parseRows<T>(
    List<dynamic> raw,
    T Function(Map<String, dynamic>) fromJson, {
    required String table,
  }) {
    final result = <T>[];
    for (var i = 0; i < raw.length; i++) {
      try {
        result.add(fromJson(raw[i] as Map<String, dynamic>));
      } catch (e) {
        debugPrint(
          '[SupabaseStore] Skipping bad row $i in $table: $e\n  row: ${raw[i]}',
        );
      }
    }
    return result;
  }

  static Map<String, dynamic> _productToSupabaseJson(Product p) => {
    'id': p.id,
    'title': p.title,
    'description': p.description,
    'category_id': p.categoryId,
    'price': p.price,
    'original_price': p.originalPrice,
    'rating': p.rating,
    'review_count': p.reviewCount,
    'stock': p.stock,
    'images': p.images,
    'available_sizes': p.availableSizes,
    'available_colors': p.availableColors,
    'is_featured': p.isFeatured,
    'is_flash_deal': p.isFlashDeal,
    'badge': p.badge,
    'specifications': p.specifications,
    'is_active': true,
  };

  static Map<String, dynamic> _categoryToSupabaseJson(Category c) => {
    'id': c.id,
    'name': c.name,
    'description': c.description,
    'image_path': c.imagePath,
    'icon_code': c.iconData.codePoint,
  };

  static Map<String, dynamic> _bannerToSupabaseJson(BannerItem b) => {
    'id': b.id,
    'title': b.title,
    'subtitle': b.subtitle,
    'image_path': b.imagePath,
    'target_category_id': b.targetCategoryId,
    'badge': b.badge,
    'is_active': true,
  };
}
