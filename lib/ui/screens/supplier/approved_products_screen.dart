import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/product.dart';
import '../../widgets/product_card.dart';

class ApprovedProductsScreen extends StatefulWidget {
  const ApprovedProductsScreen({Key? key}) : super(key: key);

  @override
  State<ApprovedProductsScreen> createState() => _ApprovedProductsScreenState();
}

class _ApprovedProductsScreenState extends State<ApprovedProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is a seller (admin)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userProfile?.userType != 'seller') {
        // Redirect to home if not a seller
        Navigator.of(context).pushReplacementNamed('/');
        return;
      }

      Provider.of<ProductProvider>(context, listen: false)
          .loadApprovedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Approved Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .loadApprovedProducts();
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
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
                      productProvider.loadApprovedProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final approvedProducts = productProvider.products;

          if (approvedProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Approved Products',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No products have been approved yet',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvedProducts.length,
            itemBuilder: (context, index) {
              final product = approvedProducts[index];
              return _buildApprovedProductCard(product, productProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovedProductCard(
      Product product, ProductProvider productProvider) {
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
          // Product Image and Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: buildProductImage(product.mainImageUrl,
                      width: 80, height: 80),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RWF ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${product.quantity}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Approved',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product.approvedBy != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Approved by: ${product.approvedBy}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                      if (product.approvedAt != null) ...[
                        Text(
                          'Approved on: ${_formatDate(product.approvedAt!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showMoveToPendingDialog(product, productProvider),
                icon: const Icon(Icons.pending_actions, color: Colors.orange),
                label: const Text(
                  'Move to Pending',
                  style: TextStyle(color: Colors.orange),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveToPendingDialog(
      Product product, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Pending'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Are you sure you want to move "${product.name}" back to pending status?'),
            const SizedBox(height: 16),
            const Text(
              'This will remove the product from the approved list and require re-approval.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action will hide the product from customers until it is re-approved.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _moveToPending(product, productProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              'Move to Pending',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _moveToPending(Product product, ProductProvider productProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Double-check that user is a seller
    if (authProvider.userProfile?.userType != 'seller') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only sellers can move products to pending'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = await productProvider.moveToPending(product.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} has been moved to pending'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to move product to pending'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
