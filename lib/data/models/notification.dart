import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 5)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId; // The user who receives the notification (the vendor)
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String message;
  @HiveField(4)
  final String orderId;
  @HiveField(5)
  final String? imageUrl;
  @HiveField(6)
  final double? price;
  @HiveField(7)
  final String? status;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.orderId,
    this.imageUrl,
    this.price,
    this.status,
    required this.createdAt,
    this.isRead = false,
  });

  // Convert a Notification object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'orderId': orderId,
      'imageUrl': imageUrl,
      'price': price,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  // Create a Notification object from a Firestore document
  factory AppNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      orderId: map['orderId'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      status: map['status'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
}
