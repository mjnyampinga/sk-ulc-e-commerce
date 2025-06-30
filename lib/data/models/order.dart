import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'cart_item.dart';

part 'order.g.dart';

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final List<CartItem> items;
  @HiveField(3)
  final double totalAmount;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final DateTime? createdAt;
  @HiveField(6)
  final DateTime? updatedAt;
  @HiveField(7)
  final String? shippingAddress;
  @HiveField(8)
  final String? paymentMethod;
  @HiveField(9)
  final List<String> supplierIds;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.shippingAddress,
    this.paymentMethod,
    this.supplierIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'supplierIds': supplierIds,
    };
  }

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'] as String,
      items: (data['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] as String,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      shippingAddress: data['shippingAddress'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      supplierIds: data['supplierIds'] != null
          ? List<String>.from(data['supplierIds'])
          : [],
    );
  }
}
