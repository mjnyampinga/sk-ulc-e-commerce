import 'package:e_commerce/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/cart_provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart' as app_auth;
import 'package:e_commerce/core/services/product_provider.dart';
import 'package:e_commerce/core/services/navigation_provider.dart';
import 'package:e_commerce/ui/screens/splash/splash_screen.dart';
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/ui/screens/cart/checkout_screen.dart';
import 'package:e_commerce/ui/screens/auth/login_screen.dart';
import 'package:e_commerce/ui/screens/onboarding/onboarding_screen.dart';
import 'package:e_commerce/ui/main_scaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:e_commerce/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:e_commerce/core/services/notification_provider.dart';
import 'package:e_commerce/core/services/order_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/product.dart';
import 'data/models/cart_item.dart';
import 'data/models/order.dart';
import 'data/models/user.dart' as app_models;
import 'data/models/banner.dart';
import 'data/models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/models/write_action.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(app_models.UserAdapter());
  Hive.registerAdapter(AppBannerAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(WriteActionAdapter());

  bool firebaseInitialized = false;

  try {
    // Initialize with proper options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
    print('Firebase initialized successfully');
    firebaseInitialized = true;

    // Test Firebase connection
    try {
      final app = Firebase.app();
      print('Firebase app name: ${app.name}');
      print('Firebase project ID: ${app.options.projectId}');
      print('Firebase connection test successful!');
    } catch (e) {
      print('Firebase connection test failed: $e');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
    print('Firebase initialization failed. Check your configuration.');
    firebaseInitialized = false;
  }

  // Initialize providers
  final cartProvider = CartProvider();
  final authProvider = app_auth.AuthProvider();
  final productProvider = ProductProvider();
  final notificationProvider = NotificationProvider();
  final orderProvider = OrderProvider();
  final navigationProvider = NavigationProvider();

  // Initialize providers that depend on Firebase
  if (firebaseInitialized) {
    try {
      await cartProvider.loadCart();
      await authProvider.initialize();
      await productProvider.initialize();

      // Initialize Firebase services after providers are ready
      try {
        await FirebaseService.initializeMessaging();
        print('Firebase services initialized successfully');
      } catch (e) {
        print('Warning: Could not initialize Firebase messaging: $e');
      }
    } catch (e) {
      print('Warning: Could not initialize some providers: $e');
    }
  } else {
    print('Firebase not available - running in offline mode');
    // Load cart from local storage only
    try {
      await cartProvider.loadCart();
    } catch (e) {
      print('Warning: Could not load cart: $e');
    }
  }

  runApp(MyApp(
    cartProvider: cartProvider,
    authProvider: authProvider,
    productProvider: productProvider,
    notificationProvider: notificationProvider,
    orderProvider: orderProvider,
    navigationProvider: navigationProvider,
  ));

  // Listen for connectivity changes and process write queue when online
  Connectivity().onConnectivityChanged.listen((result) async {
    if (result != ConnectivityResult.none) {
      await FirebaseService.processWriteQueue();
    }
  });
}

class MyApp extends StatelessWidget {
  final CartProvider cartProvider;
  final app_auth.AuthProvider authProvider;
  final ProductProvider productProvider;
  final NotificationProvider notificationProvider;
  final OrderProvider orderProvider;
  final NavigationProvider navigationProvider;

  const MyApp({
    Key? key,
    required this.cartProvider,
    required this.authProvider,
    required this.productProvider,
    required this.notificationProvider,
    required this.orderProvider,
    required this.navigationProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider.value(value: navigationProvider),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/checkout': (context) => const CheckoutScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        // Check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Stream connection waiting...');
          return const SplashScreen();
        }

        // Check for errors
        if (snapshot.hasError) {
          print('AuthWrapper: Stream has an error: ${snapshot.error}');
          return const Scaffold(
            body: Center(
              child: Text('An error occurred. Please restart the app.'),
            ),
          );
        }

        // Check if user is authenticated
        if (snapshot.hasData) {
          // User is logged in
          print('AuthWrapper: User is authenticated (snapshot has data)');

          // Ensure AuthProvider is synced
          final authProvider =
              Provider.of<app_auth.AuthProvider>(context, listen: false);
          authProvider.syncFirebaseUser(snapshot.data);

          // Initialize notifications for the authenticated user
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notificationProvider =
                Provider.of<NotificationProvider>(context, listen: false);
            notificationProvider.fetchNotifications(snapshot.data!.uid);
          });

          return const MainScaffold();
        } else {
          // User is not logged in
          print(
              'AuthWrapper: User is not authenticated (snapshot has no data)');
          return const OnboardingScreen();
        }
      },
    );
  }
}
