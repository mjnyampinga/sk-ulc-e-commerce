import 'package:e_commerce/data/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/core/services/cart_provider.dart' as cart_service;
import 'package:e_commerce/core/services/navigation_provider.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;

  List<String> get images {
    if (widget.product.imageUrls.isNotEmpty) {
      return widget.product.imageUrls;
    }
    // Fallback to default images if no product images
    return [
      'assets/images/prod.png',
      'assets/images/product.png',
      'assets/images/prod.png',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.grey, size: 22),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                                isCollapsed: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Image & Thumbnails
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: buildProductImage(images[selectedImageIndex],
                                height: 140),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: List.generate(images.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImageIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImageIndex == index
                                  ? AppConstants.primaryColor
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: buildProductImage(images[index],
                                width: 56, height: 56),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Curved Divider
            SizedBox(
              height: 32,
              width: double.infinity,
              child: CustomPaint(
                painter: ArcPainter(),
              ),
            ),
            // Main Content Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<cart_service.CartProvider>(
                    builder: (context, cart, _) {
                      int quantity = cart.getQuantity(widget.product.id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price and Discount
                          Row(
                            children: [
                              Text(
                                'RWF${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFFF3B5B),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F6FE),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '52% OFF ends in 3 days',
                                  style: TextStyle(
                                    color: Color(0xFF1CB0F6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Stock Information
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 16,
                                color: (widget.product.quantity ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Stock: ${widget.product.quantity ?? 0}',
                                style: TextStyle(
                                  color: (widget.product.quantity ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rose face lotion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity : ${(widget.product.quantity ?? 1)}',
                            style: const TextStyle(
                              color: Color(0xFF1CB0F6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Categories : solip , kolimatrio , hellop , mafirat , mop lopiranto',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Feature Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.7,
                            children: [
                              _featureCell(
                                icon: Icons.home,
                                label: 'lightweight',
                                value: '100 Gram',
                                iconAsset: 'assets/icons/house.png',
                              ),
                              _featureCell(
                                icon: Icons.abc,
                                label: '100%',
                                value: 'Silky smooth',
                                iconAsset: 'assets/icons/nutri.png',
                              ),
                              _featureCell(
                                icon: Icons.calendar_today,
                                label: '1 Year',
                                value: 'Expiration',
                                iconAsset: 'assets/icons/nova.png',
                              ),
                              _featureCell(
                                icon: Icons.star,
                                label: '4.8',
                                value: 'Reviews',
                                iconAsset: 'assets/icons/eco.png',
                                extra: '(256)',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Bottom Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F6FE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total price',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'RWF ${widget.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF3B5B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                quantity == 0
                                    ? Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final success = await cart
                                                .addToCart(widget.product);
                                            if (success) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${widget.product.name} added to cart'),
                                                  duration: const Duration(
                                                      seconds: 1),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Cannot add more than ${widget.product.quantity ?? 0} items'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: AppConstants.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 28),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 58, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppConstants.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (quantity > 1) {
                                                  cart.updateQuantity(
                                                      widget.product.id,
                                                      quantity - 1);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Cannot decrease below 1.'),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Icon(Icons.remove,
                                                  color: Colors.white,
                                                  size: 28),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                quantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final success =
                                                    await cart.updateQuantity(
                                                        widget.product.id,
                                                        quantity + 1);
                                                if (!success) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Cannot add more than ${(widget.product.quantity ?? 1)}.'),
                                                      duration: const Duration(
                                                          seconds: 1),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 28),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.setIndex(index, context);
              // Navigate back to main scaffold
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon:
                    Image.asset('assets/icons/home.png', width: 28, height: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/product.png',
                    width: 28, height: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Image.asset('assets/icons/cart.png', width: 28, height: 28),
                    Consumer<cart_service.CartProvider>(
                      builder: (context, cart, child) {
                        final itemCount = cart.itemCount;
                        return itemCount > 0
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      itemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/video.png',
                    width: 28, height: 28),
                label: '',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _featureCell({
    required IconData icon,
    required String label,
    required String value,
    String? iconAsset,
    String? extra,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          iconAsset != null
              ? Image.asset(iconAsset, width: 32, height: 32)
              : Icon(icon, size: 32, color: AppConstants.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    if (extra != null)
                      Text(
                        ' $extra',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.primaryColor // blue color matching screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 60, size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
