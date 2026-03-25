import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_localizations.dart';
import '../core/constants/api_config.dart';
import '../models/weather_models.dart';
import '../providers/settings_provider.dart';

/// 和风天气服务类
///
/// 负责与和风天气API交互，获取天气相关数据
class QWeatherService {
  /// Dio实例，用于网络请求
  final Dio _dio;

  /// API密钥
  final String _apiKey;

  /// API基础URL
  final String _baseUrl;
  final Ref? _ref;

  String get _languageCode {
    final language = _ref?.read(settingsProvider).appLanguage;
    switch (language) {
      case AppLanguage.enUS:
        return 'en';
      case AppLanguage.zhCN:
        return 'zh';
      case AppLanguage.system:
      case null:
        return AppLocalizations.isEnglishCurrentLocale ? 'en' : 'zh';
    }
  }

  /// 构造函数
  ///
  /// [dio]: 自定义Dio实例
  /// [apiKey]: 自定义API密钥
  /// [baseUrl]: 自定义API基础URL
  QWeatherService({Dio? dio, String? apiKey, String? baseUrl, Ref? ref})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
      _apiKey = apiKey ?? ApiConfig.qweatherApiKey,
      _baseUrl = baseUrl ?? ApiConfig.qweatherBaseUrl,
      _ref = ref;

  /// 根据城市名称搜索位置
  ///
  /// [query]: 城市名称
  ///
  /// 返回位置信息
  Future<Location> searchLocation(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geo/lookup',
        queryParameters: {
          'location': query,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;
      if (data['code'] == '200' && data['location'] != null) {
        final locations = data['location'] as List;
        if (locations.isNotEmpty) {
          final loc = locations.first;
          return Location(
            id: loc['id'],
            name: loc['name'],
            adm1: loc['adm1'] ?? '',
            adm2: loc['adm2'] ?? '',
            country: loc['country'] ?? AppLocalizations.tr('中国'),
            lat: double.parse(loc['lat'].toString()),
            lon: double.parse(loc['lon'].toString()),
            tz: loc['tz'] ?? 'Asia/Shanghai',
            utcOffset: loc['utcOffset'] ?? '+08:00',
            isDefault: false,
            sortOrder: 0,
          );
        }
      }
      throw Exception('Location not found');
    } catch (e) {
      rethrow;
    }
  }

  /// 根据坐标搜索位置
  ///
  /// [lat]: 纬度
  /// [lon]: 经度
  ///
  /// 返回位置信息
  Future<Location> searchLocationByCoords(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geo/reverse',
        queryParameters: {
          'location': '$lon,$lat',
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;

      if (data['code'] == '200' && data['location'] != null) {
        final locations = data['location'] as List;
        if (locations.isNotEmpty) {
          final loc = locations.first;
          return Location(
            id: loc['id'],
            name: loc['name'],
            adm1: loc['adm1'] ?? '',
            adm2: loc['adm2'] ?? '',
            country: loc['country'] ?? AppLocalizations.tr('中国'),
            lat: double.parse(loc['lat'].toString()),
            lon: double.parse(loc['lon'].toString()),
            tz: loc['tz'] ?? 'Asia/Shanghai',
            utcOffset: loc['utcOffset'] ?? '+08:00',
            isDefault: false,
            sortOrder: 0,
          );
        }
      }

      final errorCode = data['code']?.toString() ?? 'unknown';
      if (errorCode == '404') {
        throw Exception(AppLocalizations.tr('该位置不在和风天气支持范围内（仅支持中国境内）'));
      }
      throw Exception(_getErrorMessage(errorCode));
    } on DioException catch (e) {
      String errorMsg;
      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMsg = AppLocalizations.tr('网络连接失败，请检查网络');
          break;
        case DioExceptionType.connectionTimeout:
          errorMsg = AppLocalizations.tr('连接超时，请重试');
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = AppLocalizations.tr('响应超时，请重试');
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;
          if (responseData is Map && responseData['code'] != null) {
            final code = responseData['code'].toString();
            if (code == '404') {
              errorMsg = AppLocalizations.tr('该位置不在和风天气支持范围内（仅支持中国境内）');
            } else {
              errorMsg = _getErrorMessage(code);
            }
          } else if (statusCode == 404) {
            errorMsg = AppLocalizations.tr('API地址不存在，请检查API配置');
          } else {
            errorMsg = AppLocalizations.tr(
              'HTTP错误: {code}',
              args: {'code': statusCode},
            );
          }
          break;
        default:
          errorMsg = AppLocalizations.tr('网络请求失败');
      }
      throw Exception(errorMsg);
    } catch (e) {
      rethrow;
    }
  }

  /// 根据错误码获取错误信息
  ///
  /// [code]: 错误码
  ///
  /// 返回错误信息
  String _getErrorMessage(String code) {
    switch (code) {
      case '400':
        return AppLocalizations.tr('请求错误，请检查参数');
      case '401':
        return AppLocalizations.tr('API密钥无效或已过期');
      case '402':
        return AppLocalizations.tr('超过访问次数限制');
      case '403':
        return AppLocalizations.tr('无访问权限');
      case '404':
        return AppLocalizations.tr('查询的数据不存在');
      case '429':
        return AppLocalizations.tr('请求过于频繁，请稍后再试');
      case '500':
        return AppLocalizations.tr('服务暂时不可用');
      default:
        return AppLocalizations.tr('API错误码: {code}', args: {'code': code});
    }
  }

  /// 获取当前天气
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回当前天气信息
  Future<CurrentWeather> getCurrentWeather(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather/now',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;

      if (data['code'] == '200' && data['now'] != null) {
        return CurrentWeather.fromJson(data['now']);
      }
      throw Exception('Weather data not available');
    } catch (e) {
      rethrow;
    }
  }

  /// 获取逐小时天气预报
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回逐小时天气预报列表
  Future<List<HourlyWeather>> getHourlyWeather(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather/72h',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;

      if (data['code'] == '200' && data['hourly'] != null) {
        final hourlyList = (data['hourly'] as List)
            .map((e) => HourlyWeather.fromJson(e))
            .toList();
        if (kDebugMode) {
          debugPrint(
            '[Hourly] location=$locationId code=200 count=${hourlyList.length}',
          );
        }
        return hourlyList;
      }
      if (kDebugMode) {
        debugPrint(
          '[Hourly] location=$locationId code=${data['code']} hourlyNull=${data['hourly'] == null}',
        );
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Hourly] location=$locationId exception=$e');
      }
      rethrow;
    }
  }

  /// 获取每日天气预报
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回每日天气预报列表
  Future<List<DailyWeather>> getDailyWeather(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather/7d',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;

      if (data['code'] == '200' && data['daily'] != null) {
        final dailyList = data['daily'] as List;
        return dailyList.map((e) => DailyWeather.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 获取天气预警
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回天气预警列表
  Future<List<WeatherAlert>> getWeatherAlerts(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/warning/now',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;
      if (data['code'] == '200' && data['warning'] != null) {
        return (data['warning'] as List)
            .map((e) => WeatherAlert.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 获取空气质量
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回空气质量信息
  Future<AirQuality> getAirQuality(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/air/now',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
        },
      );

      final data = response.data;
      if (data['code'] == '200' && data['now'] != null) {
        final now = data['now'];
        return AirQuality(
          aqi: now['aqi'] ?? '0',
          level: now['level'] ?? '',
          category: now['category'] ?? '',
          pm10: now['pm10'] ?? '0',
          pm2p5: now['pm2p5'] ?? '0',
          no2: now['no2'] ?? '0',
          so2: now['so2'] ?? '0',
          co: now['co'] ?? '0',
          o3: now['o3'] ?? '0',
        );
      }
      throw Exception('Air quality data not available');
    } catch (e) {
      rethrow;
    }
  }

  /// 获取天气指数
  ///
  /// [locationId]: 位置ID
  ///
  /// 返回天气指数列表
  Future<List<WeatherIndices>> getWeatherIndices(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/indices/1d',
        queryParameters: {
          'location': locationId,
          'lang': _languageCode,
          'key': _apiKey,
          'type': '1,2,3,5,6,7,8,9',
        },
      );

      final data = response.data;
      if (data['code'] == '200' && data['daily'] != null) {
        return (data['daily'] as List)
            .map((e) => WeatherIndices.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 获取完整的天气数据
  ///
  /// [locationId]: 位置ID
  /// [location]: 位置信息
  ///
  /// 返回完整的天气数据
  Future<WeatherData> getFullWeatherData(
    String locationId,
    Location location,
  ) async {
    final results = await Future.wait([
      getCurrentWeather(locationId),
      getHourlyWeather(locationId),
      getDailyWeather(locationId),
      getWeatherAlerts(locationId),
    ]);

    return WeatherData(
      location: location,
      current: results[0] as CurrentWeather,
      hourly: results[1] as List<HourlyWeather>,
      daily: results[2] as List<DailyWeather>,
      alerts: results[3] as List<WeatherAlert>,
      lastUpdated: DateTime.now(),
    );
  }
}

/// 和风天气服务Provider
///
/// 提供和风天气服务实例
final qweatherServiceProvider = Provider<QWeatherService>((ref) {
  return QWeatherService(ref: ref);
});
