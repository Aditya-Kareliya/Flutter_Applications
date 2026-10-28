import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.linux:
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7ZsJqGv5hlorRExxhJkfNCzamfghWa48',
    appId: '1:242254718668:web:d689a0c97131a522ef0469',
    messagingSenderId: '242254718668',
    projectId: 'pavanputragarbi',
    authDomain: 'pavanputragarbi.firebaseapp.com',
    storageBucket: 'pavanputragarbi.firebasestorage.app',
    measurementId: 'G-PPTXWTKRZ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7ZsJqGv5hlorRExxhJkfNCzamfghWa48',
    appId: '1:242254718668:web:d689a0c97131a522ef0469',
    messagingSenderId: '242254718668',
    projectId: 'pavanputragarbi',
    authDomain: 'pavanputragarbi.firebaseapp.com',
    storageBucket: 'pavanputragarbi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7ZsJqGv5hlorRExxhJkfNCzamfghWa48',
    appId: '1:242254718668:web:d689a0c97131a522ef0469',
    messagingSenderId: '242254718668',
    projectId: 'pavanputragarbi',
    authDomain: 'pavanputragarbi.firebaseapp.com',
    storageBucket: 'pavanputragarbi.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7ZsJqGv5hlorRExxhJkfNCzamfghWa48',
    appId: '1:242254718668:web:d689a0c97131a522ef0469',
    messagingSenderId: '242254718668',
    projectId: 'pavanputragarbi',
    authDomain: 'pavanputragarbi.firebaseapp.com',
    storageBucket: 'pavanputragarbi.firebasestorage.app',
  );
}
