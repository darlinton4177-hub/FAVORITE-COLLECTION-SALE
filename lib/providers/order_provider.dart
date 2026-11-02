import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/local_storage_service.dart';

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
    await LocalStorageService.saveOrders(_orders);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      await LocalStorageService.saveOrders(_orders);
      notifyListeners();
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
