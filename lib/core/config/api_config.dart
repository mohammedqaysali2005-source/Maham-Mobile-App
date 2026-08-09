import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String _defaultPcIp = '192.168.43.5';

  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'] ?? 'http://$_defaultPcIp:5233/api';
    if (kIsWeb || (!kIsWeb && Platform.isWindows)) {
      return envUrl.replaceAll('10.0.2.2', 'localhost').replaceAll(_defaultPcIp, 'localhost');
    }
    return envUrl;
  }

  static String get hubUrl {
    final envUrl = dotenv.env['API_HUB_URL'] ?? 'http://$_defaultPcIp:5233/hubs/board';
    if (kIsWeb || (!kIsWeb && Platform.isWindows)) {
      return envUrl.replaceAll('10.0.2.2', 'localhost').replaceAll(_defaultPcIp, 'localhost');
    }
    return envUrl;
  }
}
