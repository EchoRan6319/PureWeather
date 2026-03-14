import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用常量类
/// 包含应用的基本配置和常量
class AppConstants {
  /// 应用名称
  static const String appName = '轻氧天气';

  /// 应用版本号（从包信息动态获取）
  static String _appVersion = '4.1.0-3';
  static String get appVersion => _appVersion;

  /// 初始化应用版本号
  /// 在应用启动时调用，从 package_info_plus 获取实际版本号
  static Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (e) {
      // 如果获取失败，使用默认版本号
      _appVersion = '4.1.0-3';
    }
  }

  /// API 请求超时时间
  static const Duration apiTimeout = Duration(seconds: 15);

  /// 缓存有效期
  static const Duration cacheValidDuration = Duration(minutes: 30);

  /// 最大城市数量
  static const int maxCities = 10;

  /// 默认动画持续时间（毫秒）
  static const int defaultAnimationDuration = 300;
}

/// 天气代码工具类
/// 提供天气代码的描述、图标和温度转换功能
class WeatherCode {
  /// 天气代码到描述的映射
  static const Map<int, String> descriptions = {
    100: '晴',
    101: '多云',
    102: '少云',
    103: '晴间多云',
    104: '阴',
    150: '晴',
    151: '多云',
    152: '少云',
    153: '晴间多云',
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
    350: '阵雨',
    351: '强阵雨',
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
    456: '阵雨夹雪',
    457: '阵雪',
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

  /// 根据天气代码获取描述
  ///
  /// [code] 天气代码
  /// 返回对应的天气描述，如果没有找到则返回 '未知'
  static String getDescription(int code) {
    return descriptions[code] ?? '未知';
  }

  /// 根据天气代码获取对应的图标
  ///
  /// [code] 天气代码
  /// [isNight] 是否为夜间
  /// 返回对应的天气图标
  static IconData getWeatherIcon(int code, {bool isNight = false}) {
    if (code == 100 || code == 150) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (code == 101 ||
        code == 102 ||
        code == 103 ||
        code == 151 ||
        code == 152 ||
        code == 153) {
      return isNight ? Icons.nights_stay : Icons.wb_cloudy;
    } else if (code == 104) {
      return Icons.cloud;
    } else if ((code >= 300 && code <= 399) || code == 350 || code == 351) {
      return Icons.water_drop;
    } else if ((code >= 400 && code <= 499) || code == 456 || code == 457) {
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

  /// 温度单位转换
  ///
  /// [celsiusTemp] 摄氏度温度字符串
  /// [toFahrenheit] 是否转换为华氏度
  /// 返回转换后的温度字符串
  static String convertTemperature(
    String celsiusTemp, {
    bool toFahrenheit = false,
  }) {
    final celsius = double.tryParse(celsiusTemp);
    if (celsius == null) return celsiusTemp;

    if (toFahrenheit) {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return fahrenheit.round().toString();
    }
    return celsius.round().toString();
  }
}
