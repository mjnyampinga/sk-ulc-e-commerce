import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_commerce/l10n/app_localizations.dart';
import 'dart:async';

class OnlineOfflineIndicator extends StatefulWidget {
  const OnlineOfflineIndicator({Key? key}) : super(key: key);

  @override
  State<OnlineOfflineIndicator> createState() => _OnlineOfflineIndicatorState();
}

class _OnlineOfflineIndicatorState extends State<OnlineOfflineIndicator> {
  bool _isOnline = true;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      final result = await _connectivity.checkConnectivity();
      if (mounted) {
        setState(() {
          _isOnline = !result.contains(ConnectivityResult.none);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isOnline ? l10n.online : l10n.offline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
