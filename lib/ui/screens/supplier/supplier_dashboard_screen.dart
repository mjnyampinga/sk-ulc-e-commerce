import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/services/notification_provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/product.dart';
import 'add_product_screen.dart';
import '../menu/profile_screen.dart';
import '../menu/notification_screen.dart';
import 'package:e_commerce/data/models/order.dart' as app_order;
import 'package:intl/intl.dart';
import 'package:e_commerce/core/services/order_provider.dart';
import 'manage_banners_screen.dart';
import '../../widgets/product_card.dart';
import 'package:e_commerce/core/services/firebase_service.dart';
import 'manage_categories_screen.dart';
import 'supplier_order_history_screen.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.firebaseUser != null) {
        final supplierId = authProvider.firebaseUser!.uid;
        // Fetch both products and orders
        Provider.of<ProductProvider>(context, listen: false)
            .loadSupplierProducts(supplierId);
        Provider.of<OrderProvider>(context, listen: false)
            .fetchSupplierOrders(supplierId);
        // Initialize notifications for supplier
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(supplierId);
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildCategoriesContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Supplier Dashboard'
              : (_selectedIndex == 1
                  ? 'My Orders'
                  : _selectedIndex == 2
                      ? 'Categories'
                      : 'My Profile'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // Notification icon with badge
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
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
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                ).then((_) {
                  // Refresh products when returning from add product screen
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.isAuthenticated) {
                    Provider.of<ProductProvider>(context, listen: false)
                        .loadSupplierProducts(authProvider.firebaseUser!.uid);
                  }
                });
              },
            ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return const SupplierOrderHistoryScreen();
  }

  Widget _buildOrderCard(app_order.Order order) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final List<String> statusOptions = [
      'pending',
      'shipped',
      'delivered',
      'cancelled'
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(order.createdAt!),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            ...order.items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('${item.quantity} x ${item.product.name}'),
                    ))
                .toList(),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'RWF ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: order.status,
                  underline: Container(),
                  items: statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(value))),
                    );
                  }).toList(),
                  onChanged: (String? newStatus) {
                    if (newStatus != null) {
                      orderProvider
                          .updateOrderStatus(order.id, newStatus, order.userId)
                          .then((_) {
                        // Refresh the list after updating
                        orderProvider.fetchSupplierOrders(
                            authProvider.firebaseUser!.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Order status updated to $newStatus')),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDashboardContent() {
    return Consumer2<AuthProvider, ProductProvider>(
      builder: (context, authProvider, productProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const Center(
            child: Text('Please login as a supplier'),
          );
        }

        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (productProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${productProvider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    productProvider
                        .loadSupplierProducts(authProvider.firebaseUser!.uid);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final products = productProvider.supplierProducts;

        return Column(
          children: [
            // Dashboard Stats
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Products',
                          products.length.toString(),
                          Icons.inventory,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Featured',
                          products
                              .where((p) => p.hasDiscount)
                              .length
                              .toString(),
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.view_carousel_outlined),
                            label: const Text('Manage Banners'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageBannersScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Products List
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first product to get started',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddProductScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(
                            product, productProvider, authProvider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return const ProfileScreen(showAppBar: false);
  }

  Widget _buildCategoriesContent() {
    return const ManageCategoriesScreen();
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, ProductProvider productProvider,
      AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: buildProductImage(product.mainImageUrl, width: 60, height: 60),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.subtitle),
            const SizedBox(height: 4),
            Text(
              'RWF ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.hasDiscount)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: product.isApproved == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.isApproved == true ? 'Approved' : 'Pending Approval',
                style: TextStyle(
                  color:
                      product.isApproved == true ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(product: product),
                ),
              ).then((_) {
                if (authProvider.isAuthenticated) {
                  productProvider
                      .loadSupplierProducts(authProvider.firebaseUser!.uid);
                }
              });
            } else if (value == 'delete') {
              // Show confirmation dialog
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Product'),
                  content: Text(
                      'Are you sure you want to delete "${product.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await productProvider.deleteProduct(product.id);
                if (authProvider.firebaseUser != null) {
                  await productProvider
                      .loadSupplierProducts(authProvider.firebaseUser!.uid);
                }
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
