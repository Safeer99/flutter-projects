import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYgGet8xRvOTdWP8saGC2oVSvX0JpD1Rs',
    appId: '1:575903034210:android:1dac4ac3bc63fb5bcb1a3b',
    messagingSenderId: '575903034210',
    projectId: 'quiz-app-e1673',
    storageBucket: 'quiz-app-e1673.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6U_eSib_Rj0FOq60gwQTPqrrmF2HOLRA',
    appId: '1:575903034210:ios:b92222d0e7a671bacb1a3b',
    messagingSenderId: '575903034210',
    projectId: 'quiz-app-e1673',
    storageBucket: 'quiz-app-e1673.appspot.com',
    iosClientId: '575903034210-gruraf2vqsadbcp20ip25jbk8psq870j.apps.googleusercontent.com',
    iosBundleId: 'com.example.quizApp',
  );
}
