import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';
import '../services/location_service.dart';
import '../providers/settings_provider.dart';

/// 城市管理器类
/// 
/// 负责管理城市列表的增删改查和持久化存储
class CityManager extends StateNotifier<List<Location>> {
  /// 存储城市列表的键
  static const String _keyCities = 'saved_cities';
  /// 存储默认城市ID的键
  static const String _keyDefaultCityId = 'default_city_id';

  /// 是否已加载城市数据
  bool _isLoaded = false;

  /// 构造函数
  CityManager() : super([]) {
    _loadCities();
  }

  /// 是否已加载城市数据
  bool get isLoaded => _isLoaded;

  /// 从本地存储加载城市列表
  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getString(_keyCities);

    if (citiesJson != null) {
      final List<dynamic> decoded = jsonDecode(citiesJson);
      state = decoded.map((e) => Location.fromJson(e)).toList();
    }
    _isLoaded = true;
  }

  /// 保存城市列表到本地存储
  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCities, citiesJson);
  }

  /// 添加城市
  /// 
  /// [location]: 城市位置信息
  Future<void> addCity(Location location) async {
    // 检查是否存在重复的城市（通过ID或名称+地区）
    if (state.any((city) =>
        city.id == location.id ||
        (city.name == location.name && city.adm2 == location.adm2))) {
      return;
    }

    final newCity = location.copyWith(
      sortOrder: state.length,
      isDefault: state.isEmpty, // 如果是第一个城市，设为默认
    );

    state = [...state, newCity];
    await _saveCities();
  }

  /// 添加城市并设为默认
  /// 
  /// [location]: 城市位置信息
  /// [isLocated]: 是否为当前定位城市
  Future<void> addCityAndSetDefault(Location location,
      {bool isLocated = false}) async {
    // 如果是定位城市，检查是否已有定位城市并更新
    if (isLocated) {
      final existingLocatedIndex = state.indexWhere((c) => c.isLocated);
      if (existingLocatedIndex != -1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == existingLocatedIndex)
              location.copyWith(
                isDefault: true,
                isLocated: true,
                sortOrder: state[i].sortOrder,
              )
            else
              state[i].copyWith(isDefault: false)
        ];
        await _saveCities();
        return;
      }
    }

    // 检查是否存在重复的城市
    final existingIndex = state.indexWhere((city) =>
        city.id == location.id ||
        (city.name == location.name && city.adm2 == location.adm2));

    if (existingIndex != -1) {
      // 如果已存在，直接设为默认
      await setDefaultCity(state[existingIndex].id);
      return;
    }

    // 取消所有城市的默认状态
    state = state.map((city) => city.copyWith(isDefault: false)).toList();

    final newCity = location.copyWith(
      sortOrder: state.length,
      isDefault: true,
      isLocated: isLocated,
    );

    state = [...state, newCity];
    await _saveCities();
  }

  /// 删除城市
  /// 
  /// [cityId]: 城市ID
  Future<void> removeCity(String cityId) async {
    final cityToRemove = state.firstWhere((c) => c.id == cityId);
    final wasDefault = cityToRemove.isDefault;

    state = state.where((city) => city.id != cityId).toList();

    // 如果删除的是默认城市，将第一个城市设为默认
    if (wasDefault && state.isNotEmpty) {
      state = [state.first.copyWith(isDefault: true), ...state.skip(1)];
    }

    await _saveCities();
  }

  /// 设置默认城市
  /// 
  /// [cityId]: 城市ID
  Future<void> setDefaultCity(String cityId) async {
    state = state.map((city) {
      return city.copyWith(isDefault: city.id == cityId);
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultCityId, cityId);
    await _saveCities();
  }

  /// 更新默认城市
  /// 
  /// [newLocation]: 新的城市位置信息
  Future<void> updateDefaultCity(Location newLocation) async {
    state = state.map((city) {
      if (city.isDefault) {
        return newLocation.copyWith(
          isDefault: true,
          sortOrder: city.sortOrder,
          isLocated: city.isLocated,
        );
      }
      return city;
    }).toList();

    await _saveCities();
  }

  /// 重新排序城市
  /// 
  /// [oldIndex]: 原索引
  /// [newIndex]: 新索引
  Future<void> reorderCities(int oldIndex, int newIndex) async {
    // 处理列表重新排序的逻辑
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final newCities = List<Location>.from(state);
    final city = newCities.removeAt(oldIndex);
    newCities.insert(newIndex, city);

    // 更新排序序号
    state = newCities.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    await _saveCities();
  }

  /// 获取默认城市
  Location? get defaultCity {
    try {
      return state.firstWhere((city) => city.isDefault);
    } catch (_) {
      return state.isNotEmpty ? state.first : null;
    }
  }

  /// 是否有城市
  bool get hasCities => state.isNotEmpty;

  /// 城市数量
  int get cityCount => state.length;
}

/// 城市管理器Provider
/// 
/// 提供城市列表的状态管理
final cityManagerProvider = StateNotifierProvider<CityManager, List<Location>>((
  ref,
) {
  return CityManager();
});

/// 默认城市Provider
/// 
/// 提供当前默认城市
final defaultCityProvider = Provider<Location?>((ref) {
  final cities = ref.watch(cityManagerProvider);

  if (cities.isEmpty) {
    return null;
  }

  try {
    return cities.firstWhere((city) => city.isDefault);
  } catch (_) {
    return cities.isNotEmpty ? cities.first : null;
  }
});

/// 位置初始化状态
/// 
/// 管理位置初始化的状态
class LocationInitState {
  /// 是否已初始化
  final bool isInitialized;
  /// 当前位置
  final Location? currentLocation;
  /// 错误信息
  final String? error;

  /// 构造函数
  const LocationInitState({
    this.isInitialized = false,
    this.currentLocation,
    this.error,
  });

  /// 复制并更新状态
  /// 
  /// [isInitialized]: 新的初始化状态
  /// [currentLocation]: 新的当前位置
  /// [error]: 新的错误信息
  LocationInitState copyWith({
    bool? isInitialized,
    Location? currentLocation,
    String? error,
  }) {
    return LocationInitState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error,
    );
  }
}

/// 位置初始化管理类
/// 
/// 负责处理位置初始化和权限请求
class LocationInitNotifier extends StateNotifier<LocationInitState> {
  /// Riverpod 引用
  final Ref _ref;

  /// 构造函数
  LocationInitNotifier(this._ref) : super(const LocationInitState());

  /// 初始化位置
  /// 
  /// [force]: 是否强制重新初始化
  Future<void> initLocation({bool force = false}) async {
    if (state.isInitialized && !force) return;

    if (force) {
      state = state.copyWith(isInitialized: false);
    }

    // 延迟500ms，避免启动时过于卡顿
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      final appSettings = _ref.read(settingsProvider);
      final cityManagerNotifier = _ref.read(cityManagerProvider.notifier);
      final currentDefaultCity = _ref.read(defaultCityProvider);

      if (position != null) {
        // 根据坐标获取位置信息
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
          accuracyLevel: appSettings.locationAccuracyLevel,
        );

        // 判断是否需要切换默认城市
        bool shouldSwitch = false;

        if (currentDefaultCity == null) {
          shouldSwitch = true;
        } else {
          final latDiff = (location.lat - currentDefaultCity.lat).abs();
          final lonDiff = (location.lon - currentDefaultCity.lon).abs();
          shouldSwitch = latDiff > 0.01 || lonDiff > 0.01;
        }

        if (shouldSwitch) {
          await cityManagerNotifier.addCityAndSetDefault(location);
        }

        // 更新状态
        state = LocationInitState(
          isInitialized: true,
          currentLocation: location,
        );
      } else {
        state = LocationInitState(isInitialized: true, error: '无法获取位置');
      }
    } catch (e) {
      state = LocationInitState(isInitialized: true, error: e.toString());
    }
  }

  /// 请求位置权限
  Future<bool> requestLocationPermission() async {
    try {
      final locationService = _ref.read(locationServiceProvider);
      final hasPermission = await locationService.checkAndRequestPermission();
      return hasPermission;
    } catch (e) {
      return false;
    }
  }
}

/// 位置服务Provider
/// 
/// 提供位置服务实例
final locationServiceProvider = Provider((ref) {
  return LocationService();
});

/// 位置初始化Provider
/// 
/// 提供位置初始化状态管理
final locationInitProvider =
    StateNotifierProvider<LocationInitNotifier, LocationInitState>((ref) {
      return LocationInitNotifier(ref);
    });
