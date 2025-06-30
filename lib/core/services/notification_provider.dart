import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce/data/models/notification.dart';
import 'firebase_service.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      final box = await Hive.openBox<AppNotification>('notifications');
      if (connectivityResult != ConnectivityResult.none) {
        // Online: fetch from Firestore and update Hive
        _notifications = await FirebaseService.getNotifications(userId);
        await box.clear();
        await box.addAll(_notifications);
      } else {
        // Offline: load from Hive
        _notifications = box.values.toList();
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      await FirebaseService.markNotificationAsRead(notificationId);
      // Optionally re-fetch to ensure sync, but optimistic update is usually fine
      // await fetchNotifications(userId);
    }
  }

  Future<void> clearAll(String userId) async {
    _notifications = [];
    notifyListeners();
    await FirebaseService.clearAllNotifications(userId);
  }

  /// Real-time notifications stream for a user
  Stream<List<AppNotification>> notificationsStream(String userId) {
    return FirebaseService.notificationsStream(userId).map((notifications) {
      // Play sound for new notifications
      _playNotificationSound(notifications);
      return notifications;
    });
  }

  Future<void> _playNotificationSound(
      List<AppNotification> notifications) async {
    try {
      // Check if sound is enabled
      final prefs = await SharedPreferences.getInstance();
      final soundEnabled = prefs.getBool('notificationSoundEnabled') ?? true;

      if (!soundEnabled) return;

      // Check if there are unread notifications (new ones)
      final unreadCount = notifications.where((n) => !n.isRead).length;
      if (unreadCount > 0) {
        // Provide haptic feedback for new notifications
        HapticFeedback.lightImpact();
        print('🔊 Notification alert triggered');
      }
    } catch (e) {
      print('❌ Error with notification alert: $e');
    }
  }
}
