import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String subtitle;
  @HiveField(3)
  final List<String> imageUrls;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final double? originalPrice;
  @HiveField(6)
  final bool hasDiscount;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final int? quantity;
  @HiveField(9)
  final String? category;
  @HiveField(10)
  final String? userId;
  @HiveField(11)
  final bool? isApproved;
  @HiveField(12)
  final String? approvedBy;
  @HiveField(13)
  final DateTime? approvedAt;

  String get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrls,
    required this.price,
    required this.description,
    this.originalPrice,
    this.hasDiscount = false,
    this.quantity = 1,
    this.category,
    this.userId,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'hasDiscount': hasDiscount,
      'description': description,
      'quantity': quantity,
      'category': category,
      'userId': userId,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subtitle': subtitle,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'hasDiscount': hasDiscount,
      'description': description,
      'quantity': quantity,
      'category': category,
      'userId': userId,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      hasDiscount: json['hasDiscount'] as bool? ?? false,
      description: json['description']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      category: json['category']?.toString(),
      userId: json['userId']?.toString(),
      isApproved: json['isApproved'] as bool? ?? false,
      approvedBy: json['approvedBy']?.toString(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    var imageUrlsFromData = data['imageUrls'];
    List<String> imageUrls;

    if (imageUrlsFromData is List) {
      imageUrls = List<String>.from(imageUrlsFromData);
    } else if (imageUrlsFromData is String) {
      // Handle legacy single image URL
      imageUrls = [imageUrlsFromData];
    } else {
      imageUrls = [];
    }

    return Product(
      id: id,
      name: data['name'] as String,
      subtitle: data['subtitle'] as String? ?? '',
      imageUrls: imageUrls,
      price: (data['price'] as num).toDouble(),
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice'] as num).toDouble()
          : null,
      hasDiscount: data['hasDiscount'] as bool? ?? false,
      description: data['description'] as String,
      quantity: data['quantity'] as int? ?? 1,
      category: data['category'] as String?,
      userId: data['user_id'] as String?,
      isApproved: data['isApproved'] as bool? ?? false,
      approvedBy: data['approvedBy'] as String?,
      approvedAt: null,
    );
  }
}
