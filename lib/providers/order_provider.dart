import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_store_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = true;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _orders = await LocalStorageService.loadOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(Order order) async {
    _orders.insert(0, order);
    notifyListeners();
    // 1. Write to Supabase orders table
    final err = await SupabaseStoreService.insertOrder(order);
    if (err != null) {
      debugPrint('[OrderProvider] Failed to persist order to Supabase: $err');
    }
    // 2. Persist to local storage as cache
    await LocalStorageService.saveOrders(_orders);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
      try {
        await SupabaseStoreService.updateOrderStatus(orderId, status.name);
      } catch (e) {
        debugPrint('[OrderProvider] Supabase updateOrderStatus error: $e');
      }
      await LocalStorageService.saveOrders(_orders);
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
