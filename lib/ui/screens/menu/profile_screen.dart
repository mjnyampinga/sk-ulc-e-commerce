import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart' as app_auth;
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/user.dart' as app_user;
import 'package:e_commerce/ui/screens/supplier/supplier_dashboard_screen.dart';
import 'package:intl/intl.dart';
import 'modify_account_screen.dart';
import 'notification_screen.dart';
import '../auth/login_screen.dart';
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/order_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../onboarding/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce/core/services/firebase_service.dart';
import 'package:e_commerce/core/services/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final bool showAppBar;
  const ProfileScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _notificationSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSoundPref();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated &&
          authProvider.userProfile?.userType == 'supplier') {
        final supplierId = authProvider.firebaseUser!.uid;
        Provider.of<ProductProvider>(context, listen: false)
            .loadSupplierProducts(supplierId);
        Provider.of<OrderProvider>(context, listen: false)
            .fetchSupplierOrders(supplierId);
      }
    });
  }

  Future<void> _loadNotificationSoundPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationSoundEnabled =
          prefs.getBool('notificationSoundEnabled') ?? true;
    });
  }

  Future<void> _setNotificationSoundPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationSoundEnabled', value);
    setState(() {
      _notificationSoundEnabled = value;
    });
    await FirebaseService.initializeMessaging(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Consumer<app_auth.AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userProfile;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              // Blue header with rounded bottom corners
              Container(
                height: 273,
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top bar
                      if (widget.showAppBar)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20,
                                  child: Icon(Icons.arrow_back_ios_new,
                                      color: Colors.black),
                                ),
                              ),
                              const Text(
                                'My Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                              // Notification icon
                              Consumer<NotificationProvider>(
                                builder:
                                    (context, notificationProvider, child) {
                                  final unreadCount =
                                      notificationProvider.unreadCount;
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const NotificationScreen()),
                                          );
                                        },
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 20,
                                          child: Icon(Icons.notifications,
                                              color: AppConstants.primaryColor),
                                        ),
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 2,
                                          top: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              unreadCount > 99
                                                  ? '99+'
                                                  : unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      // Overlapping profile card
                      _dashboardCard(context, user),
                      const SizedBox(height: 32),
                      // Modify account button
                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _isLoggingOut
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ModifyAccountScreen(),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('Modify your account',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Urbanist')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Verification
                      if (user.userType == 'supplier')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 20),
                            SizedBox(width: 6),
                            Text('Not Verified',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Urbanist')),
                          ],
                        ),
                      const SizedBox(height: 24),
                      // Settings
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Row(
                              children: const [
                                Icon(Icons.settings,
                                    color: AppConstants.primaryColor, size: 26),
                                SizedBox(width: 8),
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // Notification Sound Toggle
                            SwitchListTile(
                              title: const Text('Notification Sound',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontFamily: 'Urbanist',
                                  )),
                              value: _notificationSoundEnabled,
                              onChanged: (value) =>
                                  _setNotificationSoundPref(value),
                              activeColor: AppConstants.primaryColor,
                            ),
                            const SizedBox(height: 12),
                            // Delete Account row
                            InkWell(
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Account'),
                                    content: const Text(
                                        'Are you sure you want to delete your account? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    final authProvider =
                                        Provider.of<app_auth.AuthProvider>(
                                            context,
                                            listen: false);
                                    final user = authProvider.firebaseUser;
                                    if (user != null) {
                                      final email = user.email;
                                      final password =
                                          await _showPasswordDialog(context);
                                      if (password == null) return;
                                      final cred = EmailAuthProvider.credential(
                                          email: email!, password: password);
                                      await user
                                          .reauthenticateWithCredential(cred);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .delete();
                                      await user.delete();
                                    }
                                    await authProvider.signOut();
                                    if (!mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const OnboardingScreen()),
                                      (route) => false,
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to delete account: $e'),
                                          backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppConstants.primaryColor,
                                          width: 2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: AppConstants.primaryColor,
                                        size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Help Center row
                            InkWell(
                              onTap: () async {
                                final url = Uri.parse(
                                    'https://wa.me/+250783536378'); // Replace with your WhatsApp number
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Help Center',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Logout button
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoggingOut
                                ? null
                                : () => _showLogoutDialog(context),
                            icon: _isLoggingOut
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.logout, color: Colors.white),
                            label: Text(
                                _isLoggingOut ? 'Logging out...' : 'Log out',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Urbanist')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Loading overlay
              if (_isLoggingOut)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppConstants.primaryColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Logging out...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _dashboardCard(BuildContext context, app_user.User user) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.92;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: cardWidth,
          margin: const EdgeInsets.only(top: 48),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top blue overlay
              Container(
                height: 90,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(
                      204, 139, 211, 222), // semi-transparent blue
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 28), // for logo overlap
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom white card
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: user.userType == 'supplier'
                    ? _buildSupplierDashboard(context)
                    : const SizedBox(
                        height: 20), // Or some padding for non-suppliers
              ),
            ],
          ),
        ),
        // Overlapping logo with blue border
        Positioned(
          top: 10,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF047081),
                width: 4,
              ),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierDashboard(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final totalProducts = productProvider.supplierProducts.length;
    final totalSales = orderProvider.orders
        .where(
            (order) => order.status == 'delivered' || order.status == 'shipped')
        .fold<double>(0.0, (sum, order) => sum + order.totalAmount);

    final formattedSales =
        NumberFormat.currency(locale: 'en_RW', symbol: 'RWF ')
            .format(totalSales);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'My  Dashboard',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Color(0xFF047081),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _dashboardPill('Sales', () {}),
              _dashboardPill('My products', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SupplierDashboardScreen()));
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _dashboardValue(formattedSales)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _dashboardValue('Products: ${totalProducts.toString()}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardPill(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F6FE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _dashboardValue(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while logging out
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed:
                  _isLoggingOut ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                      await _performLogout();
                      // pop everything and push the login screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: _isLoggingOut ? Colors.grey : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      await authProvider.signOut();

      // The AuthWrapper will automatically handle navigation and show splash screen
      // No need for artificial delay since authStateChanges should trigger immediately
    } catch (e) {
      // Handle any logout errors
      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter your password'),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, password),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
