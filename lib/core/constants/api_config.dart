import 'package:flutter_dotenv/flutter_dotenv.dart';

import '_env_io.dart' if (dart.library.html) '_env_web.dart' as env;

/// API configuration.
///
/// Lookup order (high to low priority):
/// 1) --dart-define
/// 2) Process environment variables (non-web only)
/// 3) .env (flutter_dotenv)
class ApiConfig {
  static String _fromEnv(String key) {
    try {
      return env.envVar(key);
    } catch (_) {
      return '';
    }
  }

  static String get qweatherApiKey {
    const fromDefine = String.fromEnvironment(
      'QWEATHER_API_KEY',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('QWEATHER_API_KEY').isNotEmpty
        ? _fromEnv('QWEATHER_API_KEY')
        : dotenv.env['QWEATHER_API_KEY'] ?? '';
  }

  static String get qweatherBaseUrl {
    const fromDefine = String.fromEnvironment(
      'QWEATHER_BASE_URL',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('QWEATHER_BASE_URL').isNotEmpty
        ? _fromEnv('QWEATHER_BASE_URL')
        : dotenv.env['QWEATHER_BASE_URL'] ?? 'https://devapi.qweather.com/v7';
  }

  static String get caiyunApiKey {
    const fromDefine = String.fromEnvironment(
      'CAIYUN_API_KEY',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('CAIYUN_API_KEY').isNotEmpty
        ? _fromEnv('CAIYUN_API_KEY')
        : dotenv.env['CAIYUN_API_KEY'] ?? '';
  }

  static String get caiyunBaseUrl {
    const fromDefine = String.fromEnvironment(
      'CAIYUN_BASE_URL',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('CAIYUN_BASE_URL').isNotEmpty
        ? _fromEnv('CAIYUN_BASE_URL')
        : dotenv.env['CAIYUN_BASE_URL'] ?? 'https://api.caiyunapp.com/v2.6';
  }

  static String get amapApiKey {
    const fromDefine = String.fromEnvironment('AMAP_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('AMAP_API_KEY').isNotEmpty
        ? _fromEnv('AMAP_API_KEY')
        : dotenv.env['AMAP_API_KEY'] ?? '';
  }

  static String get amapWebKey {
    const fromDefine = String.fromEnvironment('AMAP_WEB_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromEnv('AMAP_WEB_KEY').isNotEmpty
        ? _fromEnv('AMAP_WEB_KEY')
        : dotenv.env['AMAP_WEB_KEY'] ?? '';
  }

  static bool get isConfigured {
    return qweatherApiKey.isNotEmpty && amapApiKey.isNotEmpty;
  }
}
