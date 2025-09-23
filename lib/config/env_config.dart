import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseProjectNumber => dotenv.env['FIREBASE_PROJECT_NUMBER'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static String get androidPackageName => dotenv.env['ANDROID_PACKAGE_NAME'] ?? '';
  static String get androidCertificateHash => dotenv.env['ANDROID_CERTIFICATE_HASH'] ?? '';

  static String get hereMapsApiKey => dotenv.env['HERE_MAPS_API_KEY'] ?? '';

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}