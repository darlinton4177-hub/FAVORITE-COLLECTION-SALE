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

  DataSource _dataSource = DataSource.offline;
  String? _lastError;
  int _categoriesFetched = 0;
  int _productsFetched = 0;
  int _bannersFetched = 0;

  String _searchQuery = '';
  String? _selectedCategoryId;
  String _selectedSort = 'featured';

  final ImagePicker _picker = ImagePicker();

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<BannerItem> get banners => _banners;
  List<String> get wishlistIds => _wishlistIds;
  bool get isLoading => _isLoading;

  DataSource get dataSource => _dataSource;
  String? get lastError => _lastError;
  int get categoriesFetched => _categoriesFetched;
  int get productsFetched => _productsFetched;
  int get bannersFetched => _bannersFetched;

  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedSort => _selectedSort;

  StoreProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    _wishlistIds = await LocalStorageService.loadWishlist();

    // Fetch in parallel from Supabase
    final catResult = await SupabaseStoreService.fetchCategories();
    final prodResult = await SupabaseStoreService.fetchProducts();
    final banResult = await SupabaseStoreService.fetchBanners();

    bool hasLiveSuccess = false;
    List<String> errors = [];

    // Categories
    if (catResult.source == DataSource.live) {
      _categories = catResult.rows;
      _categoriesFetched = _categories.length;
      if (_categories.isNotEmpty) {
        await LocalStorageService.saveCategories(_categories);
        hasLiveSuccess = true;
      }
    } else {
      if (catResult.error != null) errors.add(catResult.error!);
      _categories = await LocalStorageService.loadCategories();
      _categoriesFetched = _categories.length;
    }

    // Products
    if (prodResult.source == DataSource.live) {
      _products = prodResult.rows;
      _productsFetched = _products.length;
      if (_products.isNotEmpty) {
        await LocalStorageService.saveProducts(_products);
        hasLiveSuccess = true;
      }
    } else {
      if (prodResult.error != null) errors.add(prodResult.error!);
      _products = await LocalStorageService.loadProducts();
      _productsFetched = _products.length;
    }

    // Banners
    if (banResult.source == DataSource.live) {
      _banners = banResult.rows;
      _bannersFetched = _banners.length;
      if (_banners.isNotEmpty) {
        await LocalStorageService.saveBanners(_banners);
        hasLiveSuccess = true;
      }
    } else {
      if (banResult.error != null) errors.add(banResult.error!);
      _banners = await LocalStorageService.loadBanners();
      _bannersFetched = _banners.length;
    }

    if (hasLiveSuccess) {
      _dataSource = DataSource.live;
      await LocalStorageService.markLiveFetchCompleted();
    } else if (errors.isNotEmpty) {
      _dataSource = DataSource.error;
      _lastError = errors.join('; ');
    } else {
      _dataSource = DataSource.cached;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() async {
    await init();
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
    notifyListeners();
    try {
      await SupabaseStoreService.insertProduct(product);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase insertProduct error: $e');
    }
    await LocalStorageService.saveProducts(_products);
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
      try {
        await SupabaseStoreService.updateProduct(product);
      } catch (e) {
        debugPrint('[StoreProvider] Supabase updateProduct error: $e');
      }
      await LocalStorageService.saveProducts(_products);
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    _wishlistIds.remove(productId);
    notifyListeners();
    try {
      await SupabaseStoreService.deleteProduct(productId);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase deleteProduct error: $e');
    }
    await LocalStorageService.saveProducts(_products);
    await LocalStorageService.saveWishlist(_wishlistIds);
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    notifyListeners();
    try {
      await SupabaseStoreService.insertCategory(category);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase insertCategory error: $e');
    }
    await LocalStorageService.saveCategories(_categories);
  }

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
      try {
        await SupabaseStoreService.updateCategory(category);
      } catch (e) {
        debugPrint('[StoreProvider] Supabase updateCategory error: $e');
      }
      await LocalStorageService.saveCategories(_categories);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
    try {
      await SupabaseStoreService.deleteCategory(categoryId);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase deleteCategory error: $e');
    }
    await LocalStorageService.saveCategories(_categories);
  }

  Future<void> addBanner(BannerItem banner) async {
    _banners.add(banner);
    notifyListeners();
    try {
      await SupabaseStoreService.insertBanner(banner);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase insertBanner error: $e');
    }
    await LocalStorageService.saveBanners(_banners);
  }

  Future<void> updateBanner(BannerItem banner) async {
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) {
      _banners[index] = banner;
      notifyListeners();
      try {
        await SupabaseStoreService.updateBanner(banner);
      } catch (e) {
        debugPrint('[StoreProvider] Supabase updateBanner error: $e');
      }
      await LocalStorageService.saveBanners(_banners);
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    _banners.removeWhere((b) => b.id == bannerId);
    notifyListeners();
    try {
      await SupabaseStoreService.deleteBanner(bannerId);
    } catch (e) {
      debugPrint('[StoreProvider] Supabase deleteBanner error: $e');
    }
    await LocalStorageService.saveBanners(_banners);
  }

  Future<String?> pickImageFromGallery({String bucket = 'product-images'}) async {
    return pickAndUploadImage(bucket: bucket);
  }

  Future<String?> pickAndUploadImage({String bucket = 'product-images'}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final publicUrl = await SupabaseStoreService.uploadImage(file.path, bucket);
        if (publicUrl != null) {
          return publicUrl;
        }
        final savedPath = await LocalStorageService.saveImagePermanently(file.path);
        return savedPath;
      }
    } catch (e) {
      debugPrint('Error picking or uploading image: $e');
    }
    return null;
  }
}
