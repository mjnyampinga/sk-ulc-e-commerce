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
    final count = _items.fold(0, (sum, item) => sum + item.quantity);
    print('CartProvider: itemCount = $count, items = ${_items.length}');
    return count;
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

  /// Check if a product can be added to cart (has available stock)
  bool canAddToCart(Product product) {
    final currentQuantity = getQuantity(product.id);
    final availableStock = product.quantity ?? 0;
    return currentQuantity < availableStock;
  }

  /// Get available stock for a product (total stock minus current cart quantity)
  int getAvailableStock(Product product) {
    final currentQuantity = getQuantity(product.id);
    final totalStock = product.quantity ?? 0;
    return totalStock - currentQuantity;
  }

  Future<void> loadCart() async {
    _items = await _prefsService.loadCart();
    notifyListeners();
  }

  Future<bool> addToCart(Product product, [int quantity = 1]) async {
    print('CartProvider: Adding ${product.name} to cart, quantity: $quantity');

    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    // Check if we can add the requested quantity
    final currentQuantity =
        existingIndex >= 0 ? _items[existingIndex].quantity : 0;
    final availableStock = product.quantity ?? 0;

    if (currentQuantity + quantity > availableStock) {
      print(
          'CartProvider: Cannot add more than available stock ($availableStock)');
      return false; // Cannot add more than available stock
    }

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        productId: product.id,
        product: product,
        quantity: _items[existingIndex].quantity + quantity,
      );
      print(
          'CartProvider: Updated existing item, new quantity: ${_items[existingIndex].quantity}');
    } else {
      _items.add(CartItem(
          productId: product.id, product: product, quantity: quantity));
      print('CartProvider: Added new item to cart');
    }

    await _prefsService.saveCart(_items);
    notifyListeners();
    print(
        'CartProvider: Cart updated, total items: ${_items.length}, total quantity: ${itemCount}');
    return true;
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _prefsService.saveCart(_items);
    notifyListeners();
  }

  /// Updates the quantity of a cart item. If quantity < 1, removes the item from the cart.
  /// Returns true if updated or removed, false if not found or exceeds stock.
  Future<bool> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity < 1) {
        // Remove item from cart if quantity < 1
        _items.removeAt(index);
      } else {
        // Check if new quantity exceeds available stock
        final availableStock = _items[index].product.quantity ?? 0;
        if (quantity > availableStock) {
          return false; // Cannot exceed available stock
        }

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
