import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/product.dart';
import '../../widgets/product_card.dart';

class AdminProductApprovalScreen extends StatefulWidget {
  const AdminProductApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductApprovalScreen> createState() =>
      _AdminProductApprovalScreenState();
}

class _AdminProductApprovalScreenState
    extends State<AdminProductApprovalScreen> {
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
          .loadPendingApprovalProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Product Approval',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
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
                      productProvider.loadPendingApprovalProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final pendingProducts = productProvider.products;

          if (pendingProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pending approvals',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All products have been reviewed',
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
            itemCount: pendingProducts.length,
            itemBuilder: (context, index) {
              final product = pendingProducts[index];
              return _buildPendingProductCard(product, productProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingProductCard(
      Product product, ProductProvider productProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Approval Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showRejectDialog(product, productProvider),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showApproveDialog(product, productProvider),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(Product product, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to approve "${product.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'This will make the product visible to customers.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action will make the product available for purchase by customers.',
                      style: TextStyle(
                        color: Colors.green,
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
              _approveProduct(product, productProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Approve',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _approveProduct(Product product, ProductProvider productProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Double-check that user is a seller
    if (authProvider.userProfile?.userType != 'seller') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only sellers can approve products'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final adminId = authProvider.firebaseUser?.uid ?? 'admin';

    bool success = await productProvider.approveProduct(product.id, adminId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} has been approved'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRejectDialog(Product product, ProductProvider productProvider) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${product.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _rejectProduct(product, productProvider, reasonController.text);
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _rejectProduct(
      Product product, ProductProvider productProvider, String reason) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Double-check that user is a seller
    if (authProvider.userProfile?.userType != 'seller') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only sellers can reject products'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final adminId = authProvider.firebaseUser?.uid ?? 'admin';

    bool success =
        await productProvider.rejectProduct(product.id, adminId, reason);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} has been rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
