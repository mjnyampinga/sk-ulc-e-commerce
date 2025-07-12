import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/cart_provider.dart' as cart_service;
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/services/navigation_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/supplier/supplier_dashboard_screen.dart';
import 'screens/supplier/admin_dashboard_screen.dart';
import 'widgets/online_offline_banner.dart';
import 'package:e_commerce/l10n/app_localizations.dart';
import 'package:e_commerce/core/utils/constants.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // Set the initial index in the navigation provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.setIndex(widget.initialIndex, context);
    });
  }

  void _onTabTapped(int index) {
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setIndex(index, context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('MainScaffold: user type: ${authProvider.userProfile?.userType}');
        // Check user type and redirect accordingly
        final userType = authProvider.userProfile?.userType;

        if (userType == 'seller') {
          // For sellers (admins), show admin dashboard
          return const AdminDashboardScreen();
        } else if (userType == 'supplier') {
          // For suppliers, show supplier dashboard
          return const SupplierDashboardScreen();
        } else {
          // For clients, show regular app with bottom navigation
          return _buildClientApp();
        }
      },
    );
  }

  Widget _buildClientApp() {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final List<Widget> _screens = [
      HomeScreen(),
      CategoriesScreen(),
      CartScreen(),
      MenuScreen(),
    ];

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // Online/Offline Banner
              const OnlineOfflineBanner(),
              // Main Content
              Expanded(
                child: _screens[navigationProvider.currentIndex],
              ),
            ],
          ),
          floatingActionButton:
              [0, 1, 3].contains(navigationProvider.currentIndex)
                  ? Consumer<cart_service.CartProvider>(
                      builder: (context, cart, child) {
                        // Debug information
                        print(
                            'MainScaffold FAB: cart.itemCount = ${cart.itemCount}, currentIndex = ${navigationProvider.currentIndex}');

                        // Show FAB when cart is not empty and we're on home or categories screen
                        if (cart.itemCount > 0) {
                          print(
                              'MainScaffold FAB: Showing FAB with ${cart.itemCount} items');
                          return FloatingActionButton.extended(
                            onPressed: () {
                              // Navigate to cart screen
                              navigationProvider.setIndex(2, context);
                            },
                            backgroundColor: AppConstants.primaryColor,
                            icon: const Icon(Icons.shopping_cart,
                                color: Colors.white),
                            label: Text(
                              '(${cart.itemCount})',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        print('MainScaffold FAB: Not showing FAB');
                        return const SizedBox.shrink();
                      },
                    )
                  : null,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navigationProvider.currentIndex,
            onTap: _onTabTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon:
                    Image.asset('assets/icons/home.png', width: 28, height: 28),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/product.png',
                    width: 28, height: 28),
                label: l10n.categories,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Image.asset('assets/icons/cart.png', width: 28, height: 28),
                    Consumer<cart_service.CartProvider>(
                      builder: (context, cart, child) {
                        final itemCount = cart.itemCount;
                        return itemCount > 0
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      itemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: l10n.cart,
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/video.png',
                    width: 28, height: 28),
                label: l10n.menu,
              ),
            ],
          ),
        );
      },
    );
  }
}
