import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app_localizations.dart';
import '../core/constants/api_config.dart';
import '../models/weather_models.dart';
import '../providers/settings_provider.dart';

/// 位置服务类
/// 
/// 负责处理位置相关的功能，包括权限检查、获取当前位置、根据坐标获取位置信息等
class LocationService {
  /// Dio实例，用于网络请求
  final Dio _dio;
  /// 高德地图API密钥
  final String _apiKey;

  /// 构造函数
  /// 
  /// [dio]: 自定义Dio实例
  /// [apiKey]: 自定义API密钥
  LocationService({Dio? dio, String? apiKey})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
      _apiKey = apiKey ?? ApiConfig.amapWebKey;

  /// 检查并请求位置权限
  /// 
  /// 返回是否获取到权限
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// 获取当前位置
  /// 
  /// 返回当前位置信息，失败返回null
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// 检查字段是否有效
  /// 
  /// [value]: 要检查的字段值
  /// 
  /// 返回字段是否有效
  bool _isValidField(String? value) {
    if (value == null) return false;
    if (value.isEmpty) return false;
    if (value == '[]') return false;
    return true;
  }

  /// 获取位置名称
  /// 
  /// [addressComponent]: 地址组件
  /// [city]: 城市名称
  /// [accuracyLevel]: 位置精度级别
  /// 
  /// 返回位置名称
  String _getLocationName(
    Map<String, dynamic> addressComponent,
    String city, {
    LocationAccuracyLevel? accuracyLevel,
  }) {
    String district = _isValidField(addressComponent['district'])
        ? addressComponent['district'].toString()
        : '';
    String township = _isValidField(addressComponent['township'])
        ? addressComponent['township'].toString()
        : '';
    String street = _isValidField(addressComponent['street'])
        ? addressComponent['street'].toString()
        : '';
    String streetNumber = _isValidField(addressComponent['street_number'])
        ? addressComponent['street_number'].toString()
        : '';

    if (accuracyLevel == LocationAccuracyLevel.street) {
      if (street.isNotEmpty) {
        return street + (streetNumber.isNotEmpty ? streetNumber : '');
      }
      if (township.isNotEmpty) {
        return township;
      }
    }

    if (district.isNotEmpty) {
      return district;
    }

    if (township.isNotEmpty) {
      return township;
    }

    return city.isNotEmpty ? city : AppLocalizations.tr('当前位置');
  }

  /// 根据坐标获取位置信息
  /// 
  /// [lat]: 纬度
  /// [lon]: 经度
  /// [accuracyLevel]: 位置精度级别
  /// 
  /// 返回位置信息
  Future<Location> getLocationFromCoords(
    double lat,
    double lon, {
    LocationAccuracyLevel? accuracyLevel,
  }) async {
    try {
      final response = await _dio.get(
        'https://restapi.amap.com/v3/geocode/regeo',
        queryParameters: {
          'location': '$lon,$lat',
          'key': _apiKey,
          'extensions': 'base',
        },
      );

      final data = response.data;
      if (data['status'] == '1') {
        final regeocode = data['regeocode'];
        final addressComponent = regeocode['addressComponent'];

        String province = _isValidField(addressComponent['province'])
            ? addressComponent['province'].toString()
            : '';
        String city = _isValidField(addressComponent['city'])
            ? addressComponent['city'].toString()
            : '';
        String district = _isValidField(addressComponent['district'])
            ? addressComponent['district'].toString()
            : '';
        String township = _isValidField(addressComponent['township'])
            ? addressComponent['township'].toString()
            : '';

        if (city.isEmpty) {
          city = province;
        }

        String locationName = _getLocationName(
          addressComponent,
          city,
          accuracyLevel: accuracyLevel,
        );

        if (locationName.isEmpty || locationName == AppLocalizations.tr('当前位置')) {
          if (accuracyLevel == LocationAccuracyLevel.street) {
            locationName = township.isNotEmpty
                ? township
                : district.isNotEmpty
                ? district
                : city;
          } else {
            locationName = district.isNotEmpty ? district : city;
          }
        }

        if (locationName.isEmpty) {
          locationName = province.isNotEmpty
              ? province
              : AppLocalizations.tr('当前位置');
        }

        return Location(
          id: '${lon.toStringAsFixed(2)},${lat.toStringAsFixed(2)}',
          name: locationName,
          adm1: province,
          adm2: city,
          country: AppLocalizations.tr('中国'),
          lat: lat,
          lon: lon,
          tz: 'Asia/Shanghai',
          utcOffset: '+08:00',
          isDefault: false,
          sortOrder: 0,
        );
      }
      throw Exception('Location lookup failed');
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索位置
  /// 
  /// [query]: 搜索关键词
  /// 
  /// 返回位置列表
  Future<List<Location>> searchLocations(String query) async {
    final results = <Location>[];
    final seenIds = <String>{};

    try {
      // 搜索行政区划
      final districtResponse = await _dio.get(
        'https://restapi.amap.com/v3/config/district',
        queryParameters: {
          'keywords': query,
          'key': _apiKey,
          'subdistrict': '0',
          'extensions': 'base',
        },
      );

      final districtData = districtResponse.data;
      if (districtData['status'] == '1' && districtData['districts'] != null) {
        final districts = districtData['districts'] as List;

        for (final district in districts) {
          final center = district['center']?.toString();
          if (center == null || center.isEmpty) continue;

          try {
            final coords = center.split(',');
            if (coords.length != 2) continue;

            final lon = double.parse(coords[0]);
            final lat = double.parse(coords[1]);

            final uid = '${lon.toStringAsFixed(2)},${lat.toStringAsFixed(2)}';
            if (seenIds.contains(uid)) continue;
            seenIds.add(uid);

            String name = district['name']?.toString() ?? query;
            String level = district['level']?.toString() ?? '';

            String adm1 = '';
            String adm2 = '';

            if (level == 'province') {
              adm1 = name;
              adm2 = name;
            } else if (level == 'city') {
              adm2 = name;
            } else if (level == 'district') {
              adm1 = name;
            }

            results.add(
              Location(
                id: uid,
                name: name,
                adm1: adm1,
                adm2: adm2,
                country: AppLocalizations.tr('中国'),
                lat: lat,
                lon: lon,
                tz: 'Asia/Shanghai',
                utcOffset: '+08:00',
                isDefault: false,
                sortOrder: 0,
              ),
            );
          } catch (e) {
            continue;
          }
        }
      }

      // 搜索输入提示
      final tipsResponse = await _dio.get(
        'https://restapi.amap.com/v3/assistant/inputtips',
        queryParameters: {
          'keywords': query,
          'key': _apiKey,
          'datatype': 'all',
          'citylimit': 'false',
        },
      );

      final tipsData = tipsResponse.data;
      if (tipsData['status'] == '1' && tipsData['tips'] != null) {
        final tips = tipsData['tips'] as List;

        for (final tip in tips) {
          if (tip['location'] == null) continue;

          try {
            final location = tip['location'].toString().split(',');
            if (location.length != 2) continue;

            final lon = double.parse(location[0]);
            final lat = double.parse(location[1]);

            final uid = '${lon.toStringAsFixed(2)},${lat.toStringAsFixed(2)}';
            if (seenIds.contains(uid)) continue;
            seenIds.add(uid);

            String district = tip['district']?.toString() ?? '';
            String city = tip['city']?.toString() ?? '';
            String name = tip['name']?.toString() ?? '';

            if (name.isEmpty) {
              name = district.isNotEmpty ? district : city;
            }

            if (name.isEmpty) {
              name = query;
            }

            results.add(
              Location(
                id: uid,
                name: name,
                adm1: district.isNotEmpty ? district : city,
                adm2: city,
                country: AppLocalizations.tr('中国'),
                lat: lat,
                lon: lon,
                tz: 'Asia/Shanghai',
                utcOffset: '+08:00',
                isDefault: false,
                sortOrder: 0,
              ),
            );
          } catch (e) {
            continue;
          }
        }
      }

      return results.take(20).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取位置流
  /// 
  /// 返回位置变化的流
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: Duration(seconds: 30),
      ),
    );
  }
}
