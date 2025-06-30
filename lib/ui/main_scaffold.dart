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
      navigationProvider.setIndex(widget.initialIndex);
    });
  }

  void _onTabTapped(int index) {
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is a supplier
        final isSupplier = authProvider.userProfile?.userType == 'supplier';

        if (isSupplier) {
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
    final List<Widget> _screens = [
      HomeScreen(),
      CategoriesScreen(),
      CartScreen(),
      MenuScreen(),
    ];

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: _screens[navigationProvider.currentIndex],
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
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/product.png',
                    width: 28, height: 28),
                label: '',
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
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/video.png',
                    width: 28, height: 28),
                label: '',
              ),
            ],
          ),
        );
      },
    );
  }
}
