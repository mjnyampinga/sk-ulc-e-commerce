import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart' as app_user;
import '../../data/models/product.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/order.dart' as app_order;
import '../../data/models/notification.dart';
import 'package:hive/hive.dart';
import '../../data/models/write_action.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Authentication methods
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String userType,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user profile exists, if not create a basic one
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create a basic user profile if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': email.split('@')[0], // Use email prefix as username
          'userType': 'client', // Default user type
          'createdAt': FieldValue.serverTimestamp(),
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        // Update online status for existing user
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    print('FirebaseService: signOut called');
    try {
      User? user = _auth.currentUser;
      print(
          'FirebaseService: current user before signOut: ${user?.uid ?? 'null'}');

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
        print('FirebaseService: updated user online status');
      }

      await _auth.signOut();
      print('FirebaseService: Firebase auth signOut completed');

      User? userAfter = _auth.currentUser;
      print(
          'FirebaseService: current user after signOut: ${userAfter?.uid ?? 'null'}');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore methods for products
  static Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  static Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Cart methods
  static Future<void> addToCart(String userId, CartItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.productId)
          .set(item.toMap());
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  static Future<void> removeFromCart(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  static Future<void> updateCartItem(String userId, CartItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.productId)
          .update(item.toMap());
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }

  static Future<List<CartItem>> getCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CartItem.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting cart: $e');
      return [];
    }
  }

  static Future<void> clearCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Order methods
  static Future<String?> createOrder(app_order.Order order) async {
    try {
      // Add the order to the main 'orders' collection
      DocumentReference docRef =
          await _firestore.collection('orders').add(order.toMap());

      // Create notifications for each supplier involved in the order
      await _createNotificationsForOrder(order, docRef.id);

      // Add the order to the customer's 'orders' subcollection
      await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(docRef.id)
          .set(order.toMap());

      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  static Future<void> _createNotificationsForOrder(
      app_order.Order order, String orderId) async {
    // A set to keep track of suppliers that have been notified for this order
    final notifiedSuppliers = <String>{};

    for (var item in order.items) {
      // Get the product details to find the supplierId
      Product? product = await getProductById(item.product.id);
      if (product != null &&
          product.userId != null &&
          !notifiedSuppliers.contains(product.userId!)) {
        final notification = AppNotification(
          id: '', // Firestore will generate
          userId: product.userId!, // Notify the product's supplier
          title: 'New Order Received!',
          message:
              'You have a new order (#${orderId.substring(0, 6)}) for ${item.product.name}.',
          orderId: orderId,
          imageUrl: item.product.mainImageUrl,
          price: item.product.price,
          status: order.status,
          createdAt: DateTime.now(),
        );

        // Create the notification in the top-level 'notifications' collection
        await createNotification(notification);

        // Add the supplier to the set to avoid duplicate notifications
        notifiedSuppliers.add(product.userId!);
      }
    }
  }

  static Future<void> createNotification(AppNotification notification) async {
    try {
      print('🔥 createNotification called for user: ${notification.userId}');
      print('🔥 Notification title: ${notification.title}');
      print('🔥 Notification message: ${notification.message}');

      await _firestore.collection('notifications').add(notification.toMap());
      print('✅ Notification created for user ${notification.userId}');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }

  /// Fetches all notifications for a specific user.
  static Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Marks a specific notification as read.
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Deletes all notifications for a specific user.
  static Future<void> clearAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  static Future<List<app_order.Order>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return app_order.Order.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus(
      String orderId, String newStatus, String customerId) async {
    try {
      print(
          '🔥 updateOrderStatus called: orderId=$orderId, newStatus=$newStatus, customerId=$customerId');

      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        print(
            '❌ Error: Order not found when creating status update notification.');
        return;
      }
      final order = app_order.Order.fromMap(orderDoc.data()!, orderId);
      print('✅ Order found: ${order.id}');

      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection('users')
          .doc(customerId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Order status updated in Firestore');

      // Create a notification for the customer about the status update
      final notification = AppNotification(
        id: '', // Firestore will generate
        userId: customerId,
        title: 'Order Status Updated',
        message:
            'Your order #${orderId.substring(0, 6)} has been updated to "$newStatus".',
        orderId: orderId,
        status: newStatus,
        imageUrl: order.items.isNotEmpty
            ? order.items.first.product.mainImageUrl
            : null,
        price: order.items.isNotEmpty ? order.items.first.product.price : null,
        createdAt: DateTime.now(),
      );

      print('🔥 Creating notification for customer: ${notification.title}');
      await createNotification(notification);
      print('✅ Notification created successfully');
    } catch (e) {
      print('❌ Error updating order status: $e');
    }
  }

  static Future<List<app_order.Order>> getOrdersForSupplier(
      String supplierId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('supplierIds', arrayContains: supplierId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => app_order.Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting supplier orders: $e');
      return [];
    }
  }

  // User profile methods
  static Future<app_user.User?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return app_user.User.fromMap(data);
      } else {
        // If user document doesn't exist, create a basic one
        User? currentUser = getCurrentUser();
        if (currentUser != null) {
          await _firestore.collection('users').doc(userId).set({
            'uid': userId,
            'email': currentUser.email ?? '',
            'username': currentUser.email?.split('@')[0] ?? 'User',
            'userType': 'client',
            'createdAt': FieldValue.serverTimestamp(),
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
          });

          // Return the created user profile
          return app_user.User(
            id: userId,
            email: currentUser.email ?? '',
            username: currentUser.email?.split('@')[0] ?? 'User',
            userType: 'client',
            createdAt: DateTime.now(),
            isOnline: true,
            lastSeen: DateTime.now(),
          );
        }
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Storage methods
  static Future<String?> uploadImage(String path, Uint8List imageBytes) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Messaging methods
  static Future<void> initializeMessaging([bool sound = true]) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: sound,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        if (token != null) {
          User? user = getCurrentUser();
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'fcmToken': token,
            });
          }
        }

        // Handle iOS APNS token specifically
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          try {
            String? apnsToken = await _messaging.getAPNSToken();
            if (apnsToken != null) {
              print('APNS token obtained: $apnsToken');
            } else {
              print(
                  'APNS token not available yet - this is normal during development');
            }
          } catch (e) {
            print('APNS token error (this is normal): $e');
          }
        }
      }
    } catch (e) {
      print('Error initializing messaging: $e');
    }
  }

  // Analytics methods
  static Future<void> logEvent(
      String name, Map<String, Object>? parameters) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print('Error logging analytics event: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  static Future<void> queueOrCreateOrder(app_order.Order order) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // Online: create order immediately
      await createOrder(order);
    } else {
      // Offline: queue the order
      final box = await Hive.openBox<WriteAction>('write_queue');
      final action = WriteAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'order',
        data: order.toMap(),
      );
      await box.add(action);
    }
  }

  static Future<void> queueOrUpdateUserProfile(
      String userId, Map<String, dynamic> data) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // Online: update profile immediately
      await updateUserProfile(userId, data);
    } else {
      // Offline: queue the profile update
      final box = await Hive.openBox<WriteAction>('write_queue');
      final action = WriteAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'profile_update',
        data: {'userId': userId, 'update': data},
      );
      await box.add(action);
    }
  }

  static Future<void> processWriteQueue() async {
    final box = await Hive.openBox<WriteAction>('write_queue');
    final actions = box.values.toList();
    for (final action in actions) {
      try {
        if (action.type == 'order') {
          await createOrder(app_order.Order.fromMap(action.data, ''));
        } else if (action.type == 'profile_update') {
          await updateUserProfile(action.data['userId'], action.data['update']);
        }
        await action.delete();
      } catch (e) {
        // If failed, keep in queue for next attempt
      }
    }
  }

  static Stream<List<app_order.Order>> streamOrdersForSupplier(
      String supplierId) {
    return _firestore
        .collection('orders')
        .where('supplierIds', arrayContains: supplierId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => app_order.Order.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Real-time notifications stream for a user
  static Stream<List<AppNotification>> notificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
