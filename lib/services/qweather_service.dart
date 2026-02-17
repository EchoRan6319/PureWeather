import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_config.dart';
import '../models/weather_models.dart';

class QWeatherService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  QWeatherService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )),
        _apiKey = apiKey ?? ApiConfig.qweatherApiKey,
        _baseUrl = baseUrl ?? ApiConfig.qweatherBaseUrl;

  Future<Location> searchLocation(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geo/lookup',
        queryParameters: {
          'location': query,
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
            country: loc['country'] ?? '中国',
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

  Future<Location> searchLocationByCoords(double lat, double lon) async {
    try {
      print('[QWeather] GET $_baseUrl/geo/reverse?location=$lon,$lat');
      final response = await _dio.get(
        '$_baseUrl/geo/reverse',
        queryParameters: {
          'location': '$lon,$lat',
          'key': _apiKey,
        },
      );

      final data = response.data;
      print('[QWeather] Geo reverse response: $data');
      
      if (data['code'] == '200' && data['location'] != null) {
        final locations = data['location'] as List;
        if (locations.isNotEmpty) {
          final loc = locations.first;
          return Location(
            id: loc['id'],
            name: loc['name'],
            adm1: loc['adm1'] ?? '',
            adm2: loc['adm2'] ?? '',
            country: loc['country'] ?? '中国',
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
        throw Exception('该位置不在和风天气支持范围内（仅支持中国境内）');
      }
      throw Exception(_getErrorMessage(errorCode));
    } on DioException catch (e) {
      print('[QWeather] DioException: ${e.type} - ${e.message}');
      print('[QWeather] Response: ${e.response?.data}');
      String errorMsg;
      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMsg = '网络连接失败，请检查网络';
          break;
        case DioExceptionType.connectionTimeout:
          errorMsg = '连接超时，请重试';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = '响应超时，请重试';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;
          if (responseData is Map && responseData['code'] != null) {
            final code = responseData['code'].toString();
            if (code == '404') {
              errorMsg = '该位置不在和风天气支持范围内（仅支持中国境内）';
            } else {
              errorMsg = _getErrorMessage(code);
            }
          } else if (statusCode == 404) {
            errorMsg = 'API地址不存在，请检查API配置';
          } else {
            errorMsg = 'HTTP错误: $statusCode';
          }
          break;
        default:
          errorMsg = '网络请求失败';
      }
      throw Exception(errorMsg);
    } catch (e) {
      print('[QWeather] Unknown error: $e');
      rethrow;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case '400':
        return '请求错误，请检查参数';
      case '401':
        return 'API密钥无效或已过期';
      case '402':
        return '超过访问次数限制';
      case '403':
        return '无访问权限';
      case '404':
        return '查询的数据不存在';
      case '429':
        return '请求过于频繁，请稍后再试';
      case '500':
        return '服务暂时不可用';
      default:
        return 'API错误码: $code';
    }
  }

  Future<CurrentWeather> getCurrentWeather(String locationId) async {
    try {
      print('[QWeather] GET $_baseUrl/weather/now?location=$locationId');
      final response = await _dio.get(
        '$_baseUrl/weather/now',
        queryParameters: {
          'location': locationId,
          'key': _apiKey,
        },
      );

      final data = response.data;
      print('[QWeather] Current Weather Response: $data');
      
      if (data['code'] == '200' && data['now'] != null) {
        return CurrentWeather.fromJson(data['now']);
      }
      throw Exception('Weather data not available');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HourlyWeather>> getHourlyWeather(String locationId) async {
    try {
      print('[QWeather] GET $_baseUrl/weather/72h?location=$locationId');
      final response = await _dio.get(
        '$_baseUrl/weather/72h',
        queryParameters: {
          'location': locationId,
          'key': _apiKey,
        },
      );

      final data = response.data;
      print('[QWeather] Hourly Weather Response: ${data.toString().substring(0, data.toString().length > 500 ? 500 : data.toString().length)}...');
      
      if (data['code'] == '200' && data['hourly'] != null) {
        return (data['hourly'] as List)
            .map((e) => HourlyWeather.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DailyWeather>> getDailyWeather(String locationId) async {
    try {
      print('[QWeather] GET $_baseUrl/weather/7d?location=$locationId');
      final response = await _dio.get(
        '$_baseUrl/weather/7d',
        queryParameters: {
          'location': locationId,
          'key': _apiKey,
        },
      );

      final data = response.data;
      print('[QWeather] Daily Weather Response: $data');
      
      if (data['code'] == '200' && data['daily'] != null) {
        final dailyList = data['daily'] as List;
        for (var day in dailyList) {
          print('[QWeather] Daily: ${day['fxDate']} - textDay: ${day['textDay']}, textNight: ${day['textNight']}, tempMax: ${day['tempMax']}, tempMin: ${day['tempMin']}');
        }
        return dailyList.map((e) => DailyWeather.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WeatherAlert>> getWeatherAlerts(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/warning/now',
        queryParameters: {
          'location': locationId,
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

  Future<AirQuality> getAirQuality(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/air/now',
        queryParameters: {
          'location': locationId,
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

  Future<List<WeatherIndices>> getWeatherIndices(String locationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/indices/1d',
        queryParameters: {
          'location': locationId,
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

  Future<WeatherData> getFullWeatherData(String locationId, Location location) async {
    print('[QWeather] Getting full weather data for locationId: $locationId');
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

final qweatherServiceProvider = Provider<QWeatherService>((ref) {
  return QWeatherService();
});
