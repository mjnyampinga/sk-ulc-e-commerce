import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OnlineOfflineBanner extends StatefulWidget {
  const OnlineOfflineBanner({Key? key}) : super(key: key);

  @override
  State<OnlineOfflineBanner> createState() => _OnlineOfflineBannerState();
}

class _OnlineOfflineBannerState extends State<OnlineOfflineBanner> {
  bool _isOnline = true;
  bool _showBanner = false;
  late final Connectivity _connectivity;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivity.checkConnectivity().then((result) {
      if (mounted) {
        setState(() {
          _isOnline = result != ConnectivityResult.none;
        });
      }
    });
    _connectivity.onConnectivityChanged.listen((result) {
      if (mounted) {
        final wasOnline = _isOnline;
        final isNowOnline = result != ConnectivityResult.none;

        setState(() {
          _isOnline = isNowOnline;
          // Only show banner if connectivity status actually changed
          if (wasOnline != isNowOnline) {
            _showBanner = true;
          }
        });

        // Hide banner after 3 seconds
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showBanner = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: _isOnline ? Colors.green : Colors.red,
      child: Text(
        _isOnline ? 'You are online now' : 'You are offline',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
