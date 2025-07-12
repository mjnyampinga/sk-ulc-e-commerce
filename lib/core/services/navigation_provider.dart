import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index, BuildContext context) {
    _currentIndex = index;

    // Clear any auth errors when navigating
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    } catch (e) {
      print('NavigationProvider: error: $e');
      // Ignore if auth provider is not available
    }

    notifyListeners();
  }
}
