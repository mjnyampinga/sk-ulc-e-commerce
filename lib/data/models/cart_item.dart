import 'package:hive/hive.dart';
import 'product.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final Product product;
  @HiveField(2)
  final int quantity;

  CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId']?.toString() ?? '',
        product: Product.fromJson(json['product'] ?? {}),
        quantity: json['quantity'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'product': product.toJson(),
        'quantity': quantity,
      };

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'product': product.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> data) => CartItem(
        productId: data['productId'] as String,
        product: Product.fromMap(data['product'] as Map<String, dynamic>,
            data['productId'] as String),
        quantity: data['quantity'] as int,
      );
}
