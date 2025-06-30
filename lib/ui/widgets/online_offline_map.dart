import 'package:flutter/material.dart';

class OnlineOfflineMap extends StatelessWidget {
  const OnlineOfflineMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Image.asset(
          'assets/images/map_demo.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
