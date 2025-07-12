import 'package:e_commerce/data/models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/order_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/order.dart';
import 'package:e_commerce/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../widgets/product_card.dart';

class SupplierOrderHistoryScreen extends StatefulWidget {
  const SupplierOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SupplierOrderHistoryScreen> createState() =>
      _SupplierOrderHistoryScreenState();
}

class _SupplierOrderHistoryScreenState
    extends State<SupplierOrderHistoryScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.firebaseUser != null) {
        Provider.of<OrderProvider>(context, listen: false)
            .fetchSupplierOrders(authProvider.firebaseUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.isAuthenticated &&
                  authProvider.firebaseUser != null) {
                Provider.of<OrderProvider>(context, listen: false)
                    .fetchSupplierOrders(authProvider.firebaseUser!.uid);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter('all', 'All', Colors.grey),
                  const SizedBox(width: 8),
                  _buildStatusFilter('pending', l10n.pending, Colors.orange),
                  const SizedBox(width: 8),
                  _buildStatusFilter('confirmed', l10n.confirmed, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatusFilter(
                      'processing', l10n.processing, Colors.purple),
                  const SizedBox(width: 8),
                  _buildStatusFilter('shipped', l10n.shipped, Colors.indigo),
                  const SizedBox(width: 8),
                  _buildStatusFilter('delivered', l10n.delivered, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusFilter('cancelled', l10n.cancelled, Colors.red),
                ],
              ),
            ),
          ),
          // Orders List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (orderProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${orderProvider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            if (authProvider.isAuthenticated &&
                                authProvider.firebaseUser != null) {
                              orderProvider.fetchSupplierOrders(
                                  authProvider.firebaseUser!.uid);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allOrders = orderProvider.orders;
                final filteredOrders = _selectedStatus == 'all'
                    ? allOrders
                    : allOrders
                        .where((order) =>
                            order.status.toLowerCase() == _selectedStatus)
                        .toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'all'
                              ? 'No orders yet'
                              : 'No ${_selectedStatus} orders',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Orders will appear here when customers place them',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order, l10n, orderProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
      Order order, AppLocalizations l10n, OrderProvider orderProvider) {
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
      child: Column(
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt != null
                            ? DateFormat('MMM dd, yyyy - HH:mm')
                                .format(order.createdAt!)
                            : 'Date not available',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(order.status, l10n),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Order Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.take(3).map((item) => _buildOrderItem(item)),
                if (order.items.length > 3) ...[
                  const Divider(),
                  Text(
                    '${l10n.and} ${order.items.length - 3} ${l10n.moreItems}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Order Footer with Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.total}: RWF ${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          if (order.paymentMethod != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.paymentMethod}: ${order.paymentMethod}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showOrderDetails(order, l10n),
                      child: Text(l10n.viewDetails),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status Update Buttons
                if (order.status.toLowerCase() == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateOrderStatus(
                              order, 'cancelled', orderProvider),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: Text(
                            l10n.cancelled,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(
                              order, 'confirmed', orderProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            l10n.confirmed,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status.toLowerCase() == 'confirmed') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(
                              order, 'processing', orderProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: Text(
                            l10n.processing,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status.toLowerCase() == 'processing') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(
                              order, 'shipped', orderProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                          child: Text(
                            l10n.shipped,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status.toLowerCase() == 'shipped') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(
                              order, 'delivered', orderProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            l10n.delivered,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildProductImage(item.product.mainImageUrl,
                width: 40, height: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity}x RWF ${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(
      Order order, String newStatus, OrderProvider orderProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await orderProvider.updateOrderStatus(
        order.id, newStatus, order.userId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Order status updated to ${_getStatusText(newStatus, AppLocalizations.of(context)!)}'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh orders
      if (authProvider.isAuthenticated && authProvider.firebaseUser != null) {
        orderProvider.fetchSupplierOrders(authProvider.firebaseUser!.uid);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderDetails(Order order, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.orderDetails} #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection(
                        l10n.orderItems,
                        order.items
                            .map((item) =>
                                '${item.quantity}x ${item.product.name} - RWF ${(item.product.price * item.quantity).toStringAsFixed(2)}')
                            .toList()),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                        l10n.orderStatus, [_getStatusText(order.status, l10n)]),
                    const SizedBox(height: 16),
                    _buildDetailSection(l10n.orderDate, [
                      order.createdAt != null
                          ? DateFormat('EEEE, MMMM dd, yyyy - HH:mm')
                              .format(order.createdAt!)
                          : 'Date not available'
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection(l10n.totalAmount,
                        ['RWF ${order.totalAmount.toStringAsFixed(2)}']),
                    if (order.paymentMethod != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                          l10n.paymentMethod, [order.paymentMethod!]),
                    ],
                    if (order.shippingAddress != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                          l10n.shippingAddress, [order.shippingAddress!]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'confirmed':
        return l10n.confirmed;
      case 'processing':
        return l10n.processing;
      case 'shipped':
        return l10n.shipped;
      case 'delivered':
        return l10n.delivered;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }
}
