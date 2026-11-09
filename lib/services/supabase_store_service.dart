import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/banner_item.dart';
import 'local_storage_service.dart';

class SupabaseStoreService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get _isClientReady => _client != null;

  /// Fetches live categories from Supabase, updates local cache, and falls back to cache on failure
  static Future<List<Category>> fetchCategories() async {
    if (_isClientReady && _client != null) {
      try {
        final response = await _client!.from('categories').select().order('name');
        final list = (response as List<dynamic>)
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          await LocalStorageService.saveCategories(list);
          return list;
        }
      } catch (e) {
        debugPrint('Supabase fetchCategories error (falling back to local cache): $e');
      }
    }
    return LocalStorageService.loadCategories();
  }

  /// Fetches live active products from Supabase, updates local cache, and falls back to cache on failure
  static Future<List<Product>> fetchProducts() async {
    if (_isClientReady && _client != null) {
      try {
        final response = await _client!
            .from('products')
            .select()
            .eq('is_active', true)
            .order('created_at', ascending: false);
        final list = (response as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          await LocalStorageService.saveProducts(list);
          return list;
        }
      } catch (e) {
        debugPrint('Supabase fetchProducts error (falling back to local cache): $e');
      }
    }
    return LocalStorageService.loadProducts();
  }

  /// Fetches live active promotional banners from Supabase, updates local cache, and falls back to cache on failure
  static Future<List<BannerItem>> fetchBanners() async {
    if (_isClientReady && _client != null) {
      try {
        final response = await _client!
            .from('banners')
            .select()
            .eq('is_active', true)
            .order('created_at', ascending: true);
        final list = (response as List<dynamic>)
            .map((item) => BannerItem.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          await LocalStorageService.saveBanners(list);
          return list;
        }
      } catch (e) {
        debugPrint('Supabase fetchBanners error (falling back to local cache): $e');
      }
    }
    return LocalStorageService.loadBanners();
  }
}
