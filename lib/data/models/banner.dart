import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'banner.g.dart';

@HiveType(typeId: 4)
class AppBanner extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String subtitle;
  @HiveField(4)
  final String cta; // Call to action text, e.g., a coupon code
  @HiveField(5)
  final String supplierId;
  @HiveField(6)
  final bool isActive;
  @HiveField(7)
  final DateTime createdAt;

  AppBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.supplierId,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'cta': cta,
      'supplierId': supplierId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppBanner.fromMap(Map<String, dynamic> map, String documentId) {
    return AppBanner(
      id: documentId,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      cta: map['cta'] ?? '',
      supplierId: map['supplierId'] ?? '',
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
