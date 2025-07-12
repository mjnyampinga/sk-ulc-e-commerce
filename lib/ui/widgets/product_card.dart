import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/l10n/app_localizations.dart';

Widget buildProductImage(String imageUrl,
    {double width = 100, double height = 100}) {
  if (imageUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
  return imageUrl.startsWith('http')
      ? CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
        )
      : Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final int? stockQuantity;
  final VoidCallback onAddToCart;
  final bool canAddToCart;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.stockQuantity,
    required this.onAddToCart,
    this.canAddToCart = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Card(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: buildProductImage(imageUrl,
                  width: double.infinity, height: 100),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (stockQuantity != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.stockRemaining} $stockQuantity',
                style: TextStyle(
                  color: stockQuantity! > 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canAddToCart ? AppConstants.primaryColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: canAddToCart ? onAddToCart : null,
                child: Text(
                  stockQuantity == 0 ? l10n.outOfStock : l10n.addToCart,
                  style: TextStyle(
                    color: canAddToCart ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
