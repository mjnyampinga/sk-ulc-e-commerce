import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/services/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:e_commerce/data/models/notification.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showNewNotificationBanner = false;
  String _lastNotificationCount = '0';

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the screen is first loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(authProvider.firebaseUser!.uid);
      }
    });
  }

  Map<String, List<AppNotification>> _groupNotifications(
      List<AppNotification> notifications) {
    final Map<String, List<AppNotification>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var n in notifications) {
      final createdAt =
          DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (createdAt == today) {
        if (!grouped.containsKey('Today')) {
          grouped['Today'] = [];
        }
        grouped['Today']!.add(n);
      } else if (createdAt == yesterday) {
        if (!grouped.containsKey('Yesterday')) {
          grouped['Yesterday'] = [];
        }
        grouped['Yesterday']!.add(n);
      } else {
        final key = DateFormat('MMMM d, yyyy').format(n.createdAt);
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(n);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view notifications.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty ||
                  !authProvider.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  // Add a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Notifications'),
                      content: const Text(
                          'Are you sure you want to delete all notifications?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text('Clear All',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            provider.clearAll(authProvider.firebaseUser!.uid);
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<AppNotification>>(
            stream: notificationProvider.notificationsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              final notifications = snapshot.data ?? [];

              // Check for new notifications
              final unreadCount =
                  notifications.where((n) => !n.isRead).length.toString();
              if (unreadCount != _lastNotificationCount && unreadCount != '0') {
                _lastNotificationCount = unreadCount;
                _showNewNotificationBanner = true;
                // Hide banner after 3 seconds
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showNewNotificationBanner = false;
                    });
                  }
                });
              }

              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications yet.'));
              }
              final groupedNotifications = _groupNotifications(notifications);
              final sortedKeys = groupedNotifications.keys.toList()
                ..sort((a, b) {
                  if (a == 'Today') return -1;
                  if (b == 'Today') return 1;
                  if (a == 'Yesterday') return -1;
                  if (b == 'Yesterday') return 1;
                  return b.compareTo(a); // Sort other dates descending
                });

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final groupTitle = sortedKeys[index];
                  final notificationsInGroup =
                      groupedNotifications[groupTitle]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 24, bottom: 12, left: 8),
                        child: Text(
                          groupTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ...notificationsInGroup.map((n) =>
                          _notificationCard(n, notificationProvider, userId)),
                    ],
                  );
                },
              );
            },
          ),
          // New notification banner
          if (_showNewNotificationBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.green,
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'New notification received!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationCard(
      AppNotification n, NotificationProvider provider, String userId) {
    String displayStatus;
    Color statusColor;
    Color statusBgColor;

    switch (n.status) {
      case 'pending':
      case 'shipped':
        displayStatus = 'Active';
        statusColor = const Color(0xFF2196F3); // blue
        statusBgColor = const Color(0x1A2196F3); // blue with opacity
        break;
      case 'delivered':
        displayStatus = 'Delivered';
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.withOpacity(0.1);
        break;
      default:
        displayStatus = 'Info';
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.withOpacity(0.1);
    }

    return InkWell(
      onTap: () {
        if (!n.isRead) {
          provider.markAsRead(n.id, userId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: n.imageUrl != null && n.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: n.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        width: 64,
                        height: 64,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          width: 64,
                          height: 64,
                          child: const Icon(Icons.image_not_supported)),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      width: 64,
                      height: 64,
                      child: const Icon(Icons.image_not_supported)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (n.price != null)
                              Text(
                                NumberFormat.currency(
                                        locale: 'en_RW', symbol: 'RWF ')
                                    .format(n.price),
                                style: const TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTimeAgo(n.createdAt),
                            style: const TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: n.isRead
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  displayStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
