import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    final box = await Hive.openBox<Product>('products');
    if (await _isOnline()) {
      try {
        QuerySnapshot snapshot = await _firestore.collection('products').get();
        final products = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Product.fromMap(data, doc.id);
        }).toList();
        await box.clear();
        await box.addAll(products);
        return products;
      } catch (e) {
        print('Error getting products: $e');
        return box.values.toList();
      }
    } else {
      return box.values.toList();
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    if (await _isOnline()) {
      try {
        // Convert category to lowercase for case-insensitive matching
        String lowercaseCategory = category.toLowerCase().trim();

        // Get all approved products and filter locally for case-insensitive category matching
        QuerySnapshot snapshot = await _firestore
            .collection('products')
            .where('isApproved', isEqualTo: true)
            .get();
        List<Product> allProducts = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Product.fromMap(data, doc.id);
        }).toList();

        // Filter products by category case-insensitively
        List<Product> filteredProducts = allProducts.where((product) {
          String productCategory =
              (product.category ?? '').toLowerCase().trim();
          return productCategory == lowercaseCategory;
        }).toList();

        // Update the main products box for offline use
        final allBox = await Hive.openBox<Product>('products');
        for (var product in filteredProducts) {
          await allBox.put(product.id, product);
        }
        return filteredProducts;
      } catch (e) {
        print('Error getting products by category: $e');
        // Fallback to offline logic below
      }
    }
    // OFFLINE: filter from all products
    final allBox = await Hive.openBox<Product>('products');
    String lowercaseCategory = category.toLowerCase().trim();
    return allBox.values.where((p) {
      String productCategory = (p.category ?? '').toLowerCase().trim();
      return productCategory == lowercaseCategory;
    }).toList();
  }

  // Get a single product by ID
  static Future<Product?> getProductById(String productId) async {
    if (await _isOnline()) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('products').doc(productId).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          final product = Product.fromMap(data, doc.id);
          // Optionally update Hive cache
          final box = await Hive.openBox<Product>('products');
          await box.put(productId, product);
          return product;
        }
        return null;
      } catch (e) {
        print('Error getting product: $e');
        // Try Hive fallback
        final box = await Hive.openBox<Product>('products');
        return box.get(productId);
      }
    } else {
      final box = await Hive.openBox<Product>('products');
      return box.get(productId);
    }
  }

  // Add a new product (for suppliers)
  static Future<String?> addProduct(Product product, String userId) async {
    try {
      // Add user_id to the product data
      Map<String, dynamic> productData = product.toMap();
      productData['user_id'] = userId;

      // Set approval status based on user type
      // For now, all products start as pending approval
      productData['isApproved'] = false;
      productData['approvedBy'] = null;
      productData['approvedAt'] = null;

      DocumentReference docRef =
          await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Update a product (for suppliers)
  static Future<bool> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete a product (for suppliers)
  static Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Search products by name
  static Future<List<Product>> searchProducts(String query) async {
    try {
      // Convert query to lowercase for case-insensitive search
      String lowercaseQuery = query.toLowerCase().trim();

      if (lowercaseQuery.isEmpty) {
        return [];
      }

      // First try to get all approved products and filter locally for better case-insensitive search
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isApproved', isEqualTo: true)
          .get();
      List<Product> allProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();

      // Filter products case-insensitively
      List<Product> filteredProducts = allProducts.where((product) {
        String productName = product.name.toLowerCase();
        String productSubtitle = product.subtitle.toLowerCase();
        String productCategory = (product.category ?? '').toLowerCase();

        return productName.contains(lowercaseQuery) ||
            productSubtitle.contains(lowercaseQuery) ||
            productCategory.contains(lowercaseQuery);
      }).toList();

      return filteredProducts;
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get featured products
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('hasDiscount', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting featured products: $e');
      return [];
    }
  }

  // Stream products for real-time updates
  static Stream<List<Product>> streamProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Product.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Stream products by category for real-time updates
  static Stream<List<Product>> streamProductsByCategory(String category) {
    // Convert category to lowercase for case-insensitive matching
    String lowercaseCategory = category.toLowerCase().trim();

    return _firestore.collection('products').snapshots().map((snapshot) {
      List<Product> allProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Product.fromMap(data, doc.id);
      }).toList();

      // Filter products by category case-insensitively
      return allProducts.where((product) {
        String productCategory = (product.category ?? '').toLowerCase().trim();
        return productCategory == lowercaseCategory;
      }).toList();
    });
  }

  // Add sample products for testing
  static Future<bool> addSampleProducts() async {
    try {
      print('Starting to add sample products...');

      final sampleProducts = [
        {
          'name': 'Organic Face Cream',
          'subtitle': 'Natural skincare for all skin types',
          'price': 29.99,
          'originalPrice': 39.99,
          'hasDiscount': true,
          'description': 'Hydrating face cream made with organic ingredients',
          'quantity': 50,
          'category': 'Skincare',
          'imageUrls': ['assets/images/product.png'],
          'user_id': 'VS1jhbdnrhMneiDrAyipj2Uf4aw2',
        },
        {
          'name': 'Hair Growth Serum',
          'subtitle': 'Promotes healthy hair growth',
          'price': 24.99,
          'originalPrice': 24.99,
          'hasDiscount': false,
          'description': 'Natural serum that stimulates hair follicles',
          'quantity': 30,
          'category': 'Hair Care',
          'imageUrls': ['assets/images/product1.png'],
          'user_id': 'VS1jhbdnrhMneiDrAyipj2Uf4aw2',
        },
        {
          'name': 'Vitamin C Serum',
          'subtitle': 'Brightening and anti-aging',
          'price': 34.99,
          'originalPrice': 44.99,
          'hasDiscount': true,
          'description': 'Powerful antioxidant serum for radiant skin',
          'quantity': 25,
          'category': 'Skincare',
          'imageUrls': ['assets/images/product.png'],
          'user_id': 'VS1jhbdnrhMneiDrAyipj2Uf4aw2',
        },
        {
          'name': 'Natural Lip Balm',
          'subtitle': 'Moisturizing and protective',
          'price': 12.99,
          'originalPrice': 12.99,
          'hasDiscount': false,
          'description': 'Organic lip balm with natural ingredients',
          'quantity': 100,
          'category': 'Cosmetics',
          'imageUrls': ['assets/images/product1.png'],
          'user_id': 'VS1jhbdnrhMneiDrAyipj2Uf4aw2',
        },
        {
          'name': 'Anti-Aging Night Cream',
          'subtitle': 'Deep hydration and repair',
          'price': 49.99,
          'originalPrice': 59.99,
          'hasDiscount': true,
          'description': 'Advanced night cream for skin repair',
          'quantity': 20,
          'category': 'Skincare',
          'imageUrls': ['assets/images/product.png'],
          'user_id': 'VS1jhbdnrhMneiDrAyipj2Uf4aw2',
        },
      ];

      int addedCount = 0;
      for (var productData in sampleProducts) {
        try {
          await _firestore.collection('products').add(productData);
          addedCount++;
          print('Added product: ${productData['name']}');
        } catch (e) {
          print('Error adding product ${productData['name']}: $e');
        }
      }

      print(
          'Sample products added successfully: $addedCount out of ${sampleProducts.length}');
      return addedCount == sampleProducts.length;
    } catch (e) {
      print('Error adding sample products: $e');
      return false;
    }
  }

  // Get products by supplier (user_id)
  static Future<List<Product>> getProductsBySupplier(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('user_id', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting supplier products: $e');
      return [];
    }
  }

  // Get approved products only (for customers)
  static Future<List<Product>> getApprovedProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isApproved', isEqualTo: true)
          .get();
      print('Approved products: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting approved products: $e');
      return [];
    }
  }

  // Get pending approval products (for admins)
  static Future<List<Product>> getPendingApprovalProducts() async {
    try {
      // Get all products and filter for those that are not approved
      QuerySnapshot snapshot = await _firestore.collection('products').get();

      List<Product> allProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();

      // Filter for products that are not approved (isApproved is false or null)
      List<Product> pendingProducts = allProducts.where((product) {
        return product.isApproved == false;
      }).toList();

      return pendingProducts;
    } catch (e) {
      print('Error getting pending approval products: $e');
      return [];
    }
  }

  // Approve a product (for admins)
  static Future<bool> approveProduct(
      String productId, String approvedBy) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isApproved': true,
        'approvedBy': approvedBy,
        'approvedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error approving product: $e');
      return false;
    }
  }

  // Reject a product (for admins)
  static Future<bool> rejectProduct(
      String productId, String rejectedBy, String reason) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isApproved': false,
        'rejectedBy': rejectedBy,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
      });
      return true;
    } catch (e) {
      print('Error rejecting product: $e');
      return false;
    }
  }

  // Move approved product back to pending (for admins)
  static Future<bool> moveToPending(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isApproved': false,
        'approvedBy': null,
        'approvedAt': null,
        'rejectedBy': null,
        'rejectedAt': null,
        'rejectionReason': null,
      });
      return true;
    } catch (e) {
      print('Error moving product to pending: $e');
      return false;
    }
  }
}
