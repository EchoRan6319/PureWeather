import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_config.dart';

/// 彩云天气服务类，提供分钟级降雨预报和实时天气数据
class CaiyunWeatherService {
  /// Dio实例，用于网络请求
  final Dio _dio;
  
  /// API密钥
  final String _apiKey;
  
  /// 基础URL
  final String _baseUrl;

  /// 创建彩云天气服务实例
  /// 
  /// [dio] Dio实例，默认为新创建的实例
  /// [apiKey] API密钥，默认为ApiConfig中的配置
  /// [baseUrl] 基础URL，默认为ApiConfig中的配置
  CaiyunWeatherService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )),
        _apiKey = apiKey ?? ApiConfig.caiyunApiKey,
        _baseUrl = baseUrl ?? ApiConfig.caiyunBaseUrl;

  /// 获取分钟级降雨预报
  /// 
  /// [lat] 纬度
  /// [lon] 经度
  /// 
  /// 返回CaiyunMinuteRain实例
  Future<CaiyunMinuteRain> getMinuteRain(double lat, double lon) async {
    final response = await _dio.get(
      '$_baseUrl/$_apiKey/$lon,$lat/forecast',
    );

    final data = response.data;
    if (data['status'] == 'ok') {
      return CaiyunMinuteRain.fromJson(data);
    }
    throw Exception('Caiyun weather data not available');
  }

  /// 获取实时天气数据
  /// 
  /// [lat] 纬度
  /// [lon] 经度
  /// 
  /// 返回实时天气数据的Map
  Future<Map<String, dynamic>> getRealtimeWeather(double lat, double lon) async {
    final response = await _dio.get(
      '$_baseUrl/$_apiKey/$lon,$lat/realtime',
    );

    final data = response.data;
    if (data['status'] == 'ok') {
      return data['result'];
    }
    throw Exception('Caiyun realtime data not available');
  }
}

/// 彩云分钟级降雨预报类
class CaiyunMinuteRain {
  /// 状态
  final String status;
  
  /// 描述
  final String description;
  
  /// 降雨数据列表
  final List<MinuteRainItem> precipitation;
  
  /// 降雨概率
  final double probability;

  /// 创建彩云分钟级降雨预报实例
  /// 
  /// [status] 状态
  /// [description] 描述
  /// [precipitation] 降雨数据列表
  /// [probability] 降雨概率
  CaiyunMinuteRain({
    required this.status,
    required this.description,
    required this.precipitation,
    required this.probability,
  });

  /// 从JSON创建彩云分钟级降雨预报实例
  /// 
  /// [json] JSON数据
  factory CaiyunMinuteRain.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final minutely = result['minutely'] ?? {};
    final precipitation2h = minutely['precipitation_2h'] ?? [];
    
    return CaiyunMinuteRain(
      status: json['status'] ?? '',
      description: minutely['description'] ?? '',
      precipitation: (precipitation2h as List)
          .asMap()
          .entries
          .map((e) => MinuteRainItem(
                minute: e.key * 5,
                value: (e.value as num).toDouble(),
              ))
          .toList(),
      probability: (minutely['probability'] ?? 0.0).toDouble(),
    );
  }

  /// 是否会下雨（概率大于30%）
  bool get willRain => probability > 0.3;
  
  /// 是否有大雨（任何时刻降雨量大于5mm）
  bool get heavyRainComing => precipitation.any((p) => p.value > 5);
}

/// 分钟降雨数据项
class MinuteRainItem {
  /// 分钟数
  final int minute;
  
  /// 降雨量（mm）
  final double value;

  /// 创建分钟降雨数据项实例
  /// 
  /// [minute] 分钟数
  /// [value] 降雨量（mm）
  MinuteRainItem({required this.minute, required this.value});
}

/// 彩云天气服务的Provider
final caiyunWeatherServiceProvider = Provider<CaiyunWeatherService>((ref) {
  return CaiyunWeatherService();
});
