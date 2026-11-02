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
        debugPrint('Error decoding saved products: $e');
      }
    }
    final initial = DemoStoreData.getInitialProducts();
    await saveProducts(initial);
    return initial;
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
        debugPrint('Error decoding saved categories: $e');
      }
    }
    final initial = DemoStoreData.getInitialCategories();
    await saveCategories(initial);
    return initial;
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
        debugPrint('Error decoding saved banners: $e');
      }
    }
    final initial = DemoStoreData.getInitialBanners();
    await saveBanners(initial);
    return initial;
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
