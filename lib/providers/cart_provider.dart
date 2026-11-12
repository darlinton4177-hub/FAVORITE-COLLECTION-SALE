import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/banner_item.dart';
import '../config/store_config.dart';
import '../data/demo_store_data.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Coupon? _appliedCoupon;
  String _shippingMethod = 'standard'; // standard or express

  Map<String, CartItem> get items => _items;
  List<CartItem> get cartList => _items.values.toList();
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  Coupon? get appliedCoupon => _appliedCoupon;
  String get shippingMethod => _shippingMethod;

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discount {
    if (_appliedCoupon == null) return 0.0;
    return _appliedCoupon!.calculateDiscount(subtotal);
  }

  double get shippingFee {
    if (_items.isEmpty) return 0.0;
    if (_shippingMethod == 'express') {
      return StoreConfig.expressShippingFee;
    }
    return (subtotal >= StoreConfig.freeShippingThreshold)
        ? 0.0
        : StoreConfig.standardShippingFee;
  }

  double get estimatedTax {
    final taxable = (subtotal - discount).clamp(0.0, double.infinity);
    return taxable * StoreConfig.estimatedTaxRate;
  }

  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    final total = subtotal - discount + shippingFee + estimatedTax;
    return total < 0 ? 0.0 : total;
  }

  void setShippingMethod(String method) {
    _shippingMethod = method;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    // TODO: Fetch live coupons from Supabase in future. For now uses bundled coupon data.
    final coupons = DemoStoreData.getDemoCoupons();
    try {
      final found = coupons.firstWhere((c) => c.code == cleanCode);
      if (subtotal >= found.minOrderAmount) {
        _appliedCoupon = found;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void addToCart(
    Product product, {
    int quantity = 1,
    String selectedSize = '',
    String selectedColor = '',
  }) {
    final key = '${product.id}_${selectedSize.trim()}_${selectedColor.trim()}';
    if (_items.containsKey(key)) {
      final existing = _items[key]!;
      _items[key] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items[key] = CartItem(
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQty) {
    if (!_items.containsKey(cartItemId)) return;
    if (newQty <= 0) {
      _items.remove(cartItemId);
    } else {
      _items[cartItemId] = _items[cartItemId]!.copyWith(quantity: newQty);
    }
    if (_appliedCoupon != null && subtotal < _appliedCoupon!.minOrderAmount) {
      _appliedCoupon = null;
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.remove(cartItemId);
    if (_appliedCoupon != null && subtotal < _appliedCoupon!.minOrderAmount) {
      _appliedCoupon = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }
}
