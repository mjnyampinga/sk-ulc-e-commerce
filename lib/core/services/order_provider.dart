import 'package:flutter/material.dart';
import 'package:e_commerce/data/models/order.dart';
import 'firebase_service.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSupplierOrders(String supplierId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      final box = await Hive.openBox<Order>('orders');
      if (connectivityResult != ConnectivityResult.none) {
        // Online: fetch from Firestore and update Hive
        _orders = await FirebaseService.getOrdersForSupplier(supplierId);
        await box.clear();
        await box.addAll(_orders);
      } else {
        // Offline: load from Hive
        _orders = box.values.toList();
      }
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(
      String orderId, String newStatus, String customerId) async {
    try {
      // Find the order in the local list and update it for an immediate UI response
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // This is tricky because Order is immutable. We need to create a new one.
        // For now, let's just refetch the list for simplicity.
        // A more advanced implementation would replace the item in the list.
      }

      await FirebaseService.updateOrderStatus(orderId, newStatus, customerId);
      // Re-fetch the orders to get the updated list.
      // We need the supplier ID, which we don't have here.
      // This suggests the UI will need to call fetchSupplierOrders again after an update.
      // For now, let's just make the API call. The UI will have to handle refreshing.
    } catch (e) {
      // Handle error, maybe set an error state
      print('Failed to update order status: $e');
    }
  }

  // Add a method to place an order using the queue
  Future<void> placeOrder(Order order) async {
    await FirebaseService.queueOrCreateOrder(order);
    // Optionally refresh orders after placing
    if (order.userId.isNotEmpty) {
      await fetchSupplierOrders(order.userId);
    }
  }
}
