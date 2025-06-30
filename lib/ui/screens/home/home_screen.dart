import 'package:flutter/material.dart';
import '../menu/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/cart_provider.dart' as cart_service;
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/navigation_provider.dart';
import '../../../core/services/product_service.dart';
import '../../widgets/product_card.dart';
import '../categories/product_detail_screen.dart';
import 'dart:async';
import 'package:e_commerce/core/services/category_service.dart';
import 'package:e_commerce/data/models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showAllPopular = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late final PageController _bannerController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.88);
    _startBannerAutoSlide();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      if (!productProvider.isInitialized) {
        productProvider.initialize();
      }
    });
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBanner + 1;
        if (nextPage >= 3) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      // Clear search and load all products
      setState(() {
        _isSearching = false;
      });
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProducts();
    } else {
      // Live search - search immediately
      setState(() {
        _isSearching = true;
      });
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.searchProducts(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    setState(() {
      _isSearching = false;
    });
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardSize = 210;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double viewportFraction = cardSize / screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFF5F9FF),
              elevation: 0,
              toolbarHeight: 0,
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: const Color(0xFFF5F9FF),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Color(0xFF2A7A92)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Kigali, kg 34 st...',
                                        style: TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart,
                                      color: Color(0xFF2A7A92)),
                                  const SizedBox(width: 4),
                                  Consumer<cart_service.CartProvider>(
                                    builder: (context, cart, child) => Text(
                                      'RWF${cart.totalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Color(0xFFE0E0E0),
                                child: Image.asset(
                                  'assets/icons/profile.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                  decoration: const InputDecoration(
                                    hintText: 'What are u looking for ?',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  onChanged: _onSearchChanged,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: _clearSearch,
                                  child: const Icon(Icons.clear,
                                      color: Colors.grey),
                                ),
                              if (_searchQuery.isEmpty)
                                const Icon(Icons.camera_alt_outlined,
                                    color: Color(0xFF2A7A92)),
                            ],
                          ),
                        ),
                      ),
                      // Banner Carousel
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: PageView(
                            controller: _bannerController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentBanner = index;
                              });
                            },
                            children: [
                              _buildBannerCard(
                                  'Shop now', 'Pay Later !', 'OCTOBER7'),
                              _buildBannerCard(
                                  'Big Sale', 'Up to 70% Off', 'SALE2024'),
                              _buildBannerCard(
                                  'New Arrivals', 'Fresh & Trendy', 'NEW2024'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Categories',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Image.asset('assets/icons/emoji.png', width: 24),
                          ],
                        ),
                        TextButton(
                            onPressed: () {
                              final navigationProvider =
                                  Provider.of<NavigationProvider>(context,
                                      listen: false);
                              navigationProvider
                                  .setIndex(1); // Switch to categories tab
                            },
                            child: const Text('See all')),
                      ],
                    ),
                  ),
                  _buildCategoriesRow(),
                  // Product Carousel - Now using Firebase products
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      if (productProvider.isLoading) {
                        return SizedBox(
                          height: 210,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  _isSearching
                                      ? 'Searching...'
                                      : 'Loading products...',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (productProvider.error != null) {
                        return SizedBox(
                          height: 210,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading products: ${productProvider.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_isSearching) {
                                      productProvider
                                          .searchProducts(_searchQuery);
                                    } else {
                                      productProvider.loadProducts();
                                    }
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products = productProvider.products;

                      if (products.isEmpty) {
                        return SizedBox(
                          height: 210,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSearching
                                      ? Icons.search_off
                                      : Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isSearching
                                      ? 'No products found for "$_searchQuery"'
                                      : 'No products available',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_isSearching) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Try different keywords or check spelling',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                if (!_isSearching) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final success = await ProductService
                                            .addSampleProducts();
                                        if (success) {
                                          await productProvider.loadProducts();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Sample products added successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Some products failed to add. Check console for details.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Add Sample Products'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isSearching) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      color: Color(0xFF2A7A92), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Search results for "$_searchQuery" (${products.length} found)',
                                      style: const TextStyle(
                                        color: Color(0xFF2A7A92),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _clearSearch,
                                    child: const Icon(Icons.clear,
                                        color: Colors.grey, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(
                            height: 210,
                            width: double.infinity,
                            child: PageView.builder(
                              controller: PageController(
                                  viewportFraction: viewportFraction),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return Consumer<cart_service.CartProvider>(
                                  builder: (context, cart, _) {
                                    final quantity =
                                        cart.getQuantity(product.id);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailScreen(
                                                      product: product),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 210,
                                          height: 210,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16)),
                                                    child: buildProductImage(
                                                        product.mainImageUrl,
                                                        width: double.infinity,
                                                        height: 100),
                                                  ),
                                                  if (product.hasDiscount)
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.blue[50],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Text(
                                                            '52% Off',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product.name,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        product.subtitle,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      const Spacer(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'RWF ${product.price.toStringAsFixed(2)}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF2A7A92)),
                                                              ),
                                                              if (product
                                                                      .hasDiscount &&
                                                                  product.originalPrice !=
                                                                      null)
                                                                Text(
                                                                  'RWF ${product.originalPrice!.toStringAsFixed(2)}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough),
                                                                ),
                                                            ],
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              if (quantity >
                                                                  0) {
                                                                cart.updateQuantity(
                                                                    product.id,
                                                                    quantity +
                                                                        1);
                                                              } else {
                                                                cart.addToCart(
                                                                    product);
                                                              }
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0xFF2A7A92),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: quantity >
                                                                      0
                                                                  ? Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            cart.updateQuantity(product.id,
                                                                                quantity - 1);
                                                                          },
                                                                          child:
                                                                              const Icon(
                                                                            Icons.remove,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                          quantity
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            cart.updateQuantity(product.id,
                                                                                quantity + 1);
                                                                          },
                                                                          child:
                                                                              const Icon(
                                                                            Icons.add,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : const Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Popular Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Popular Products',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Image.asset('assets/icons/celebrate.png',
                                width: 24),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showAllPopular = !showAllPopular;
                            });
                          },
                          child: Text(showAllPopular ? 'Show Less' : 'See All'),
                        ),
                      ],
                    ),
                  ),
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      final featuredProducts = productProvider.featuredProducts;

                      if (featuredProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      if (!showAllPopular) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                      product: featuredProducts[0]),
                                ),
                              );
                            },
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16)),
                                    child: buildProductImage(
                                        featuredProducts[0].mainImageUrl,
                                        width: 80,
                                        height: 80),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          featuredProducts[0].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          featuredProducts[0].subtitle,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                            'RWF${featuredProducts[0].price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Consumer<cart_service.CartProvider>(
                                    builder: (context, cart, _) {
                                      final quantity = cart
                                          .getQuantity(featuredProducts[0].id);
                                      return quantity == 0
                                          ? GestureDetector(
                                              onTap: () {
                                                cart.addToCart(
                                                    featuredProducts[0]);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF2A7A92),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () =>
                                                        cart.updateQuantity(
                                                            featuredProducts[0]
                                                                .id,
                                                            quantity - 1),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFF2A7A92)
                                                            .withAlpha(26),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color:
                                                            Color(0xFF2A7A92),
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                      quantity.toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      cart.updateQuantity(
                                                          featuredProducts[0]
                                                              .id,
                                                          quantity + 1);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFF2A7A92),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: featuredProducts.length,
                            itemBuilder: (context, index) {
                              final product = featuredProducts[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                                product: product),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              bottomLeft: Radius.circular(16)),
                                          child: buildProductImage(
                                              product.mainImageUrl,
                                              width: 80,
                                              height: 80),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                product.subtitle,
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                  'RWF${product.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Consumer<cart_service.CartProvider>(
                                          builder: (context, cart, _) {
                                            final quantity =
                                                cart.getQuantity(product.id);
                                            return quantity == 0
                                                ? GestureDetector(
                                                    onTap: () {
                                                      cart.addToCart(product);
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFF2A7A92),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () => cart
                                                              .updateQuantity(
                                                                  product.id,
                                                                  quantity - 1),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                      0xFF2A7A92)
                                                                  .withAlpha(
                                                                      26),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.remove,
                                                              color: Color(
                                                                  0xFF2A7A92),
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            quantity.toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            cart.updateQuantity(
                                                                product.id,
                                                                quantity + 1);
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xFF2A7A92),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(String title, String subtitle, String tag) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A7A92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset('assets/images/banner.png', height: 65),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return StreamBuilder<List<Category>>(
      stream: CategoryService.streamCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: cat.icon != null && cat.icon!.isNotEmpty
                          ? (cat.icon!.startsWith('assets/')
                              ? Image.asset(cat.icon!, width: 28)
                              : Image.network(cat.icon!,
                                  width: 28,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.category)))
                          : const Icon(Icons.category, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(cat.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
