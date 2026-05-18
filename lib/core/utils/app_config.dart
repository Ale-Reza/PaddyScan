import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _ipKey = 'server_ip';
  static const String _defaultIp = '192.168.100.101';

  // Get full base URL
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_ipKey) ?? _defaultIp;
    return 'http://$ip:5000';
  }

  // Get just the IP
  static Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? _defaultIp;
  }
}
