import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBeb-374I7xHa2bW0DmXg6IbLL1gkmM-s0',
    appId: '1:1033718427781:web:85a74e23edc544522af9ec',
    messagingSenderId: '1033718427781',
    projectId: 'e-commerce-5ee74',
    authDomain: 'e-commerce-5ee74.firebaseapp.com',
    storageBucket: 'e-commerce-5ee74.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeb-374I7xHa2bW0DmXg6IbLL1gkmM-s0',
    appId: '1:1033718427781:android:85a74e23edc544522af9ec',
    messagingSenderId: '1033718427781',
    projectId: 'e-commerce-5ee74',
    storageBucket: 'e-commerce-5ee74.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBeb-374I7xHa2bW0DmXg6IbLL1gkmM-s0',
    appId: '1:1033718427781:ios:85a74e23edc544522af9ec',
    messagingSenderId: '1033718427781',
    projectId: 'e-commerce-5ee74',
    storageBucket: 'e-commerce-5ee74.firebasestorage.app',
    iosBundleId: 'com.example.eCommerce',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBeb-374I7xHa2bW0DmXg6IbLL1gkmM-s0',
    appId: '1:1033718427781:ios:85a74e23edc544522af9ec',
    messagingSenderId: '1033718427781',
    projectId: 'e-commerce-5ee74',
    storageBucket: 'e-commerce-5ee74.firebasestorage.app',
    iosBundleId: 'com.example.eCommerce',
  );
}
