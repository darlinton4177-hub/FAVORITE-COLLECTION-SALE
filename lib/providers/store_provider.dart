import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/banner_item.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_store_service.dart';

class StoreProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<BannerItem> _banners = [];
  List<String> _wishlistIds = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String? _selectedCategoryId;
  String _selectedSort = 'featured';

  final ImagePicker _picker = ImagePicker();

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<BannerItem> get banners => _banners;
  List<String> get wishlistIds => _wishlistIds;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedSort => _selectedSort;

  StoreProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _wishlistIds = await LocalStorageService.loadWishlist();

    // Fetch live from Supabase (with automatic fallback to local cache)
    _banners = await SupabaseStoreService.fetchBanners();
    _categories = await SupabaseStoreService.fetchCategories();
    _products = await SupabaseStoreService.fetchProducts();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> list = List.from(_products);

    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.badge.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q);
      }).toList();
    }

    switch (_selectedSort) {
      case 'price_low':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'featured':
      default:
        list.sort((a, b) {
          if (a.isFeatured == b.isFeatured) return 0;
          return a.isFeatured ? -1 : 1;
        });
        break;
    }

    return list;
  }

  List<Product> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  List<Product> get flashDeals =>
      _products.where((p) => p.isFlashDeal).toList();

  List<Product> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  Future<void> toggleWishlist(String productId) async {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    await LocalStorageService.saveWishlist(_wishlistIds);
    notifyListeners();
  }

  Product? findProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Category? findCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    await LocalStorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await LocalStorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    _wishlistIds.remove(productId);
    await LocalStorageService.saveProducts(_products);
    await LocalStorageService.saveWishlist(_wishlistIds);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await LocalStorageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await LocalStorageService.saveCategories(_categories);
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    await LocalStorageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> addBanner(BannerItem banner) async {
    _banners.add(banner);
    await LocalStorageService.saveBanners(_banners);
    notifyListeners();
  }

  Future<void> updateBanner(BannerItem banner) async {
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) {
      _banners[index] = banner;
      await LocalStorageService.saveBanners(_banners);
      notifyListeners();
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    _banners.removeWhere((b) => b.id == bannerId);
    await LocalStorageService.saveBanners(_banners);
    notifyListeners();
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final savedPath = await LocalStorageService.saveImagePermanently(
          file.path,
        );
        return savedPath;
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }
}
