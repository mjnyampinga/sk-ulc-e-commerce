import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_commerce/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const SizedBox.shrink();
    }

    if (!_showBanner) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green : Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline ? l10n.youAreOnline : l10n.youAreOffline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
