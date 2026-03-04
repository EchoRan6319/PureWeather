import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 配置类
/// 用于从环境变量中读取各种 API 密钥和基础 URL
class ApiConfig {
  /// 和风天气 API 密钥
  static String get qweatherApiKey => dotenv.env['QWEATHER_API_KEY'] ?? '';
  
  /// 和风天气 API 基础 URL
  static String get qweatherBaseUrl => dotenv.env['QWEATHER_BASE_URL'] ?? 'https://devapi.qweather.com/v7';
  
  /// 彩云天气 API 密钥
  static String get caiyunApiKey => dotenv.env['CAIYUN_API_KEY'] ?? '';
  
  /// 彩云天气 API 基础 URL
  static String get caiyunBaseUrl => dotenv.env['CAIYUN_BASE_URL'] ?? 'https://api.caiyunapp.com/v2.6';
  
  /// 高德地图 API 密钥
  static String get amapApiKey => dotenv.env['AMAP_API_KEY'] ?? '';
  
  /// 高德地图 Web API 密钥
  static String get amapWebKey => dotenv.env['AMAP_WEB_KEY'] ?? '';
  
  /// DeepSeek AI API 密钥
  static String get deepseekApiKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  
  /// DeepSeek AI API 基础 URL
  static String get deepseekBaseUrl => dotenv.env['DEEPSEEK_BASE_URL'] ?? 'https://api.deepseek.com/v1';
  
  /// 检查必要的 API 配置是否完成
  /// 
  /// 返回 true 表示至少配置了和风天气和高德地图的 API 密钥
  static bool get isConfigured {
    return qweatherApiKey.isNotEmpty && 
           amapApiKey.isNotEmpty;
  }
}
