import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import 'product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _supplierProducts = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get supplierProducts => _supplierProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  ProductProvider() {
    // Don't load products in constructor - wait for Firebase to be ready
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await loadProducts();
    await loadFeaturedProducts();
    _isInitialized = true;
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      // Load only approved products for customers
      _products = await ProductService.getApprovedProducts();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load products: $e');
      _setLoading(false);
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await ProductService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      print('Error loading featured products: $e');
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await ProductService.getProductsByCategory(category);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load products: $e');
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await ProductService.searchProducts(query);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to search products: $e');
      _setLoading(false);
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      return await ProductService.getProductById(productId);
    } catch (e) {
      _setError('Failed to get product: $e');
      return null;
    }
  }

  Future<void> loadSupplierProducts(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _supplierProducts = await ProductService.getProductsBySupplier(userId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load supplier products: $e');
      _setLoading(false);
    }
  }

  Future<bool> addProduct(Product product, String userId) async {
    try {
      String? productId = await ProductService.addProduct(product, userId);
      if (productId != null) {
        await loadProducts(); // Reload all products
        await loadSupplierProducts(userId); // Reload supplier products
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      bool success = await ProductService.updateProduct(productId, data);
      if (success) {
        await loadProducts(); // Reload products
      }
      return success;
    } catch (e) {
      _setError('Failed to update product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      bool success = await ProductService.deleteProduct(productId);
      if (success) {
        await loadProducts(); // Reload products
      }
      return success;
    } catch (e) {
      _setError('Failed to delete product: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    String lowercaseCategory = category.toLowerCase().trim();
    return _products.where((product) {
      String productCategory = (product.category ?? '').toLowerCase().trim();
      return productCategory == lowercaseCategory;
    }).toList();
  }

  // Get product by ID from local list
  Product? getProductByIdLocal(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Admin methods for product approval
  Future<void> loadPendingApprovalProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await ProductService.getPendingApprovalProducts();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load pending approval products: $e');
      _setLoading(false);
    }
  }

  Future<bool> approveProduct(String productId, String approvedBy) async {
    try {
      bool success = await ProductService.approveProduct(productId, approvedBy);
      if (success) {
        await loadPendingApprovalProducts(); // Reload pending products
      }
      return success;
    } catch (e) {
      _setError('Failed to approve product: $e');
      return false;
    }
  }

  Future<bool> rejectProduct(
      String productId, String rejectedBy, String reason) async {
    try {
      bool success =
          await ProductService.rejectProduct(productId, rejectedBy, reason);
      if (success) {
        await loadPendingApprovalProducts(); // Reload pending products
      }
      return success;
    } catch (e) {
      _setError('Failed to reject product: $e');
      return false;
    }
  }

  // Load approved products (for admin review)
  Future<void> loadApprovedProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await ProductService.getApprovedProducts();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load approved products: $e');
      _setLoading(false);
    }
  }

  // Move approved product back to pending
  Future<bool> moveToPending(String productId) async {
    try {
      bool success = await ProductService.moveToPending(productId);
      if (success) {
        await loadApprovedProducts(); // Reload approved products
      }
      return success;
    } catch (e) {
      _setError('Failed to move product to pending: $e');
      return false;
    }
  }
}
