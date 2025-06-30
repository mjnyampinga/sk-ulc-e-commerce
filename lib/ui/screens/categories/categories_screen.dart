import 'package:flutter/material.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/data/models/product.dart';
import 'package:e_commerce/core/services/cart_provider.dart' as cart_service;
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/ui/screens/categories/product_detail_screen.dart';
import '../../widgets/product_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../widgets/online_offline_banner.dart';
import 'package:e_commerce/core/services/category_service.dart';
import 'package:e_commerce/data/models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedCategoryIndex = 0;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isOnline = true;
  late final Connectivity _connectivity;
  late final StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivity.checkConnectivity().then((result) {
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
      }
    });
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _isOnline =
              results.any((result) => result != ConnectivityResult.none);
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      if (!productProvider.isInitialized) {
        productProvider.initialize();
      } else {
        productProvider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index, List<Category> categories) {
    setState(() {
      selectedCategoryIndex = index;
    });
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    if (index == 0) {
      productProvider.loadProducts();
    } else {
      productProvider.loadProductsByCategory(categories[index - 1].name);
    }
  }

  void _onSearchChanged(String query, List<Category> categories) {
    setState(() {
      searchQuery = query;
    });
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    if (query.isEmpty) {
      if (selectedCategoryIndex == 0) {
        productProvider.loadProducts();
      } else {
        productProvider
            .loadProductsByCategory(categories[selectedCategoryIndex - 1].name);
      }
    } else {
      productProvider.searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: CategoryService.streamCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: const Color(0xFFF5F9FF),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(categories),
                _buildCategoryTabs(categories),
                const OnlineOfflineBanner(),
                Expanded(
                  child: _buildProductGrid(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.grey, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (q) => _onSearchChanged(q, categories),
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(List<Category> categories) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          final label = index == 0 ? 'All' : categories[index - 1].name;
          return GestureDetector(
            onTap: () => _onCategorySelected(index, categories),
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16 : 24,
                right: index == categories.length ? 16 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color:
                          isSelected ? AppConstants.primaryColor : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 24,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }
        if (productProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading products',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  productProvider.error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategoryIndex == 0) {
                      productProvider.loadProducts();
                    } else {
                      // This will be handled by the category tabs
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final products = productProvider.products;
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No products found for "$searchQuery"'
                      : 'No products available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.isNotEmpty
                      ? 'Try adjusting your search terms'
                      : 'Check back later for new products',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Consumer<cart_service.CartProvider>(
      builder: (context, cart, _) {
        final quantity = cart.getQuantity(product.id);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE6F6FE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: buildProductImage(product.mainImageUrl,
                          width: double.infinity, height: 120),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 218, 247, 254),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${((product.originalPrice! - product.price) / product.originalPrice! * 100).round()}%',
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Off',
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Add icon or quantity selector
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: quantity == 0
                        ? GestureDetector(
                            onTap: () {
                              cart.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 22),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    cart.updateQuantity(
                                        product.id, quantity - 1);
                                  },
                                  child: const Icon(Icons.remove,
                                      color: Colors.white, size: 22),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    cart.updateQuantity(
                                        product.id, quantity + 1);
                                  },
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 22),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Flexible(
                              child: Text(
                                'RWF${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.originalPrice != null) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'RWF${product.originalPrice!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${((product.originalPrice! - product.price) / product.originalPrice! * 100).round()}% Off',
                                  style: const TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
