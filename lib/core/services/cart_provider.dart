import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/models/product.dart';
import 'package:e_commerce/data/models/cart_item.dart';
import 'package:e_commerce/core/services/shared_prefs_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  final SharedPrefsService _prefsService = SharedPrefsService();

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
          productId: productId,
          product: Product(
              id: productId,
              name: '',
              subtitle: '',
              price: 0,
              imageUrls: [],
              description: ''),
          quantity: 0),
    );
    return item.quantity;
  }

  Future<void> loadCart() async {
    _items = await _prefsService.loadCart();
    notifyListeners();
  }

  Future<void> addToCart(Product product, [int quantity = 1]) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        productId: product.id,
        product: product,
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
          productId: product.id, product: product, quantity: quantity));
    }

    await _prefsService.saveCart(_items);
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _prefsService.saveCart(_items);
    notifyListeners();
  }

  /// Updates the quantity of a cart item. If quantity < 1, removes the item from the cart.
  /// Returns true if updated or removed, false if not found.
  Future<bool> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity < 1) {
        // Remove item from cart if quantity < 1
        _items.removeAt(index);
      } else {
        _items[index] = CartItem(
          productId: productId,
          product: _items[index].product,
          quantity: quantity,
        );
      }
      await _prefsService.saveCart(_items);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> clearCart() async {
    _items.clear();
    await _prefsService.saveCart(_items);
    notifyListeners();
  }
}
