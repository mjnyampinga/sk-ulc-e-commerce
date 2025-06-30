import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? createdBy;
  final Timestamp? createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.createdBy,
    this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
