import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/banner_item.dart';
import '../models/order.dart';
import '../models/user_profile.dart';
// DemoStoreData is only used in debug mode — never imported for production fallback
import '../data/demo_store_data.dart';

class LocalStorageService {
  static const String keyProducts = 'fcs_products';
  static const String keyCategories = 'fcs_categories';
  static const String keyBanners = 'fcs_banners';
  static const String keyOrders = 'fcs_orders';
  static const String keyWishlist = 'fcs_wishlist';
  static const String keyUserProfile = 'fcs_user_profile';
  static const String keyThemeMode = 'fcs_theme_mode';
  static const String keyHasSeenOnboarding = 'fcs_has_seen_onboarding';
  /// Set to true the first time a successful live fetch overwrites the cache.
  static const String keyLiveFetchCompleted = 'fcs_live_fetch_completed';

  /// Call this after a successful live fetch to clear any old demo seed.
  static Future<void> markLiveFetchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyLiveFetchCompleted) != true) {
      await prefs.setBool(keyLiveFetchCompleted, true);
      debugPrint('[LocalStorage] First live fetch completed — demo seed cleared.');
    }
  }

  static Future<String> saveImagePermanently(String sourcePath) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) {
        return sourcePath;
      }
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/imported_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final filename =
          'img_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final savedImage = await file.copy('${imagesDir.path}/$filename');
      return savedImage.path;
    } catch (e) {
      debugPrint('Failed to copy image to local permanent storage: $e');
      return sourcePath;
    }
  }

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyProducts);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStorage] Error decoding cached products: $e');
      }
    }
    // In debug mode, seed with demo data so the app is usable offline.
    // In release, return empty — the UI will show an error/retry banner.
    if (kDebugMode) {
      final initial = DemoStoreData.getInitialProducts();
      await saveProducts(initial);
      return initial;
    }
    return [];
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(products.map((e) => e.toJson()).toList());
    await prefs.setString(keyProducts, jsonStr);
  }

  static Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyCategories);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStorage] Error decoding cached categories: $e');
      }
    }
    if (kDebugMode) {
      final initial = DemoStoreData.getInitialCategories();
      await saveCategories(initial);
      return initial;
    }
    return [];
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(keyCategories, jsonStr);
  }

  static Future<List<BannerItem>> loadBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyBanners);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[LocalStorage] Error decoding cached banners: $e');
      }
    }
    if (kDebugMode) {
      final initial = DemoStoreData.getInitialBanners();
      await saveBanners(initial);
      return initial;
    }
    return [];
  }

  static Future<void> saveBanners(List<BannerItem> banners) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(banners.map((e) => e.toJson()).toList());
    await prefs.setString(keyBanners, jsonStr);
  }

  static Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyOrders);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error decoding saved orders: $e');
      }
    }
    return [];
  }

  static Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(keyOrders, jsonStr);
  }

  static Future<List<String>> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyWishlist) ?? [];
  }

  static Future<void> saveWishlist(List<String> wishlist) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyWishlist, wishlist);
  }

  static Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyUserProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return UserProfile.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        debugPrint('Error decoding user profile: $e');
      }
    }
    return const UserProfile();
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserProfile, jsonEncode(profile.toJson()));
  }

  static Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyThemeMode) ?? 'system';
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, mode);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyHasSeenOnboarding) ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyHasSeenOnboarding, seen);
  }
}
