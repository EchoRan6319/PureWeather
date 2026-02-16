import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '轻氧天气';
  static const String appVersion = '1.2.1';

  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration cacheValidDuration = Duration(minutes: 30);

  static const int maxCities = 10;
  static const int defaultAnimationDuration = 300;
}

class WeatherCode {
  static const Map<int, String> descriptions = {
    100: '晴',
    101: '多云',
    102: '少云',
    103: '晴间多云',
    104: '阴',
    150: '晴',
    151: '多云',
    300: '阵雨',
    301: '强阵雨',
    302: '雷阵雨',
    303: '强雷阵雨',
    304: '雷阵雨伴有冰雹',
    305: '小雨',
    306: '中雨',
    307: '大雨',
    308: '极端降雨',
    309: '毛毛雨',
    310: '暴雨',
    311: '大暴雨',
    312: '特大暴雨',
    313: '冻雨',
    314: '小到中雨',
    315: '中到大雨',
    316: '大到暴雨',
    317: '暴雨到大暴雨',
    318: '大暴雨到特大暴雨',
    399: '雨',
    400: '小雪',
    401: '中雪',
    402: '大雪',
    403: '暴雪',
    404: '雨夹雪',
    405: '雨雪天气',
    406: '阵雨夹雪',
    407: '阵雪',
    408: '小到中雪',
    409: '中到大雪',
    410: '大到暴雪',
    499: '雪',
    500: '薄雾',
    501: '雾',
    502: '霾',
    503: '扬沙',
    504: '浮尘',
    507: '沙尘暴',
    508: '强沙尘暴',
    509: '浓雾',
    510: '强浓雾',
    511: '中度霾',
    512: '重度霾',
    513: '严重霾',
    514: '大雾',
    515: '特强浓雾',
    900: '热',
    901: '冷',
    999: '未知',
  };

  static String getDescription(int code) {
    return descriptions[code] ?? '未知';
  }

  static IconData getWeatherIcon(int code, {bool isNight = false}) {
    if (code == 100 || code == 150) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (code == 101 || code == 102 || code == 103 || code == 151) {
      return isNight ? Icons.nights_stay : Icons.wb_cloudy;
    } else if (code == 104) {
      return Icons.cloud;
    } else if (code >= 300 && code <= 399) {
      return Icons.water_drop;
    } else if (code >= 400 && code <= 499) {
      return Icons.ac_unit;
    } else if (code >= 500 && code <= 515) {
      return Icons.blur_on;
    } else if (code == 900) {
      return Icons.thermostat;
    } else if (code == 901) {
      return Icons.severe_cold;
    }
    return Icons.cloud_queue;
  }
}
