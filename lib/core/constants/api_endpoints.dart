import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
  // 🌐 Hugging Face hosted backend (production)
  static const String _hostedUrl = 'https://HAFALI-paddyscan-backend.hf.space';

  // 🔧 Local fallback for development
  static const String _defaultIp = '192.168.100.101';
  static const String _defaultPort = '7860';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final useLocal = prefs.getBool('use_local_server') ?? false;

    if (useLocal) {
      final ip = prefs.getString('server_ip') ?? _defaultIp;
      if (kDebugMode) print('=== USING LOCAL SERVER: $ip');
      return 'http://$ip:$_defaultPort';
    }

    if (kDebugMode) print('=== USING HOSTED SERVER: $_hostedUrl');
    return _hostedUrl;
  }

  static Future<String> getFullUrl(String endpoint) async {
    final base = await getBaseUrl();
    return '$base$endpoint';
  }

  // Endpoints
  static const String health = '/health';
  static const String modelInfo = '/model-info';
  static const String validate = '/api/validate';
  static const String classify = '/api/classify';
  static const String detect = '/api/detect';
  static const String diagnose = '/api/diagnose';
  static const String preview = '/api/preview';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
