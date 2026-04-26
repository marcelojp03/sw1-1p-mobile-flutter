import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static Future<void> initEnvironment() async {
    await dotenv.load(fileName: '.env');
    log('apiUrl: $apiUrl');
  }

  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:8080/api';
}
