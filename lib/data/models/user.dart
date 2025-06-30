import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? phone;
  @HiveField(4)
  final String userType;
  @HiveField(5)
  final DateTime? createdAt;
  @HiveField(6)
  final bool isOnline;
  @HiveField(7)
  final DateTime? lastSeen;
  @HiveField(8)
  final String? fcmToken;
  @HiveField(9)
  final DateTime? dateOfBirth;
  @HiveField(10)
  final String? addressLine1;
  @HiveField(11)
  final String? addressLine2;
  @HiveField(12)
  final String? city;
  @HiveField(13)
  final String? postalCode;
  @HiveField(14)
  final String? country;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.userType,
    this.createdAt,
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
    this.dateOfBirth,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'username': username,
      'email': email,
      'phone': phone,
      'userType': userType,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'fcmToken': fcmToken,
      'dateOfBirth': dateOfBirth,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['uid'] as String,
      username: data['username'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      userType: data['userType'] as String,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] as bool? ?? false,
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcmToken'] as String?,
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      addressLine1: data['addressLine1'] as String?,
      addressLine2: data['addressLine2'] as String?,
      city: data['city'] as String?,
      postalCode: data['postalCode'] as String?,
      country: data['country'] as String?,
    );
  }
}
