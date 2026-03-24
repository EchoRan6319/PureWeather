import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../services/qweather_service.dart';
import '../services/caiyun_service.dart';
import '../services/notification_service.dart';
import '../services/live_update_diagnostics_service.dart';
import 'city_provider.dart';
import 'settings_provider.dart';

/// 天气加载状态枚举
///
/// - initial: 初始状态
/// - loading: 加载中
/// - loaded: 加载完成
/// - error: 加载失败
enum WeatherLoadingState { initial, loading, loaded, error }

/// 天气状态类
///
/// 管理天气相关的所有状态数据，包括核心天气数据、空气质量和分钟级降雨预报
class WeatherState {
  /// 加载状态
  final WeatherLoadingState loadingState;

  /// 核心天气数据
  final WeatherData? weatherData;

  /// 空气质量数据
  final AirQuality? airQuality;

  /// 分钟级降雨预报
  final CaiyunMinuteRain? minuteRain;

  /// 生活指数数据
  final List<WeatherIndices>? weatherIndices;

  /// 错误信息
  final String? errorMessage;

  /// 构造函数
  const WeatherState({
    this.loadingState = WeatherLoadingState.initial,
    this.weatherData,
    this.airQuality,
    this.minuteRain,
    this.weatherIndices,
    this.errorMessage,
  });

  /// 复制并更新状态
  ///
  /// [loadingState]: 新的加载状态
  /// [weatherData]: 新的天气数据
  /// [airQuality]: 新的空气质量数据
  /// [minuteRain]: 新的分钟级降雨预报
  /// [weatherIndices]: 新的生活指数数据
  /// [errorMessage]: 新的错误信息
  /// [clearError]: 是否清除错误信息
  /// [clearWeather]: 是否清除天气数据
  WeatherState copyWith({
    WeatherLoadingState? loadingState,
    WeatherData? weatherData,
    AirQuality? airQuality,
    CaiyunMinuteRain? minuteRain,
    List<WeatherIndices>? weatherIndices,
    String? errorMessage,
    bool clearError = false,
    bool clearWeather = false,
  }) {
    return WeatherState(
      loadingState: loadingState ?? this.loadingState,
      weatherData: clearWeather ? null : (weatherData ?? this.weatherData),
      airQuality: clearWeather ? null : (airQuality ?? this.airQuality),
      minuteRain: clearWeather ? null : (minuteRain ?? this.minuteRain),
      weatherIndices: clearWeather
          ? null
          : (weatherIndices ?? this.weatherIndices),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// 是否正在加载
  bool get isLoading => loadingState == WeatherLoadingState.loading;

  /// 是否有数据
  bool get hasData => weatherData != null;

  /// 是否有错误
  bool get hasError => errorMessage != null;
}

/// 天气状态管理类
///
/// 负责处理天气数据的加载、刷新和通知等操作
class WeatherNotifier extends StateNotifier<WeatherState> {
  /// 和风天气服务
  final QWeatherService _qweatherService;

  /// 彩云天气服务
  final CaiyunWeatherService _caiyunService;

  /// Riverpod 引用
  final Ref _ref;

  /// 已显示的预警ID集合，用于避免重复显示通知
  final Set<String> _shownAlertIds = {};

  /// 构造函数
  WeatherNotifier(this._ref, this._qweatherService, this._caiyunService)
    : super(const WeatherState());

  /// 加载指定位置的天气数据
  ///
  /// [location]: 位置信息
  Future<void> loadWeather(Location location) async {
    // 更新状态为加载中
    state = state.copyWith(
      loadingState: WeatherLoadingState.loading,
      clearError: true,
    );

    try {
      // 1. 获取核心天气数据 (和风天气)
      final weatherData = await _qweatherService.getFullWeatherData(
        location.id,
        location,
      );

      // 2. 尝试获取辅助数据，但不让它们阻塞核心数据
      AirQuality? airQuality;
      try {
        airQuality = await _qweatherService.getAirQuality(location.id);
      } catch (e) {
        debugPrint('加载空气质量失败: $e');
      }

      CaiyunMinuteRain? minuteRain;
      try {
        minuteRain = await _caiyunService.getMinuteRain(
          location.lat,
          location.lon,
        );
      } catch (e) {
        debugPrint('加载彩云天气失败: $e');
      }

      // 3. 获取生活指数数据
      List<WeatherIndices>? weatherIndices;
      try {
        weatherIndices = await _qweatherService.getWeatherIndices(location.id);
      } catch (e) {
        debugPrint('加载生活指数失败: $e');
      }

      // 更新状态为加载完成
      state = WeatherState(
        loadingState: WeatherLoadingState.loaded,
        weatherData: weatherData,
        airQuality: airQuality,
        minuteRain: minuteRain,
        weatherIndices: weatherIndices,
      );

      // 自动持久化缓存数据，供定时播报回退使用
      _saveWeatherCache(location.id, weatherData);

      // 清理孤儿数据（异步执行，不阻塞主流程）
      _cleanupWeatherCache();

      // 检查并发送天气预警通知
      await _checkAndSendAlertNotifications(weatherData.alerts);

      // 同步 Android 实时更新通知
      await syncAndroidLiveUpdateNotificationWithSettings(
        scene: 'weather_load',
      );
    } catch (e) {
      // 更新状态为错误
      state = state.copyWith(
        loadingState: WeatherLoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 检查并发送天气预警通知
  ///
  /// [alerts]: 天气预警列表
  Future<void> _checkAndSendAlertNotifications(
    List<WeatherAlert> alerts,
  ) async {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;

    final hasPermission = await notificationServiceProvider
        .checkNotificationPermission();
    if (!hasPermission) return;

    for (final alert in alerts) {
      if (!_shownAlertIds.contains(alert.id)) {
        await notificationServiceProvider.showWeatherWarningAlert(
          alertType: alert.typeName,
          severity: _getSeverityText(alert.level),
          description: _truncateText(alert.text, 100),
        );
        _shownAlertIds.add(alert.id);
      }
    }
  }

  /// 根据当前设置与天气状态，同步 Android 实时更新通知
  Future<void> syncAndroidLiveUpdateNotificationWithSettings({
    String scene = 'weather_sync',
  }) async {
    final settings = _ref.read(settingsProvider);
    bool? isAndroid;
    bool? hasWeatherData;
    bool? isSupported;
    bool? hasNotificationPermission;
    bool? hasPromotedPermission;
    bool? promotableCharacteristics;
    String? titlePreview;

    if (!settings.androidLiveUpdateNotificationEnabled) {
      await notificationServiceProvider.cancelAndroidLiveWeatherUpdate();
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'SETTING_DISABLED',
        message: '实时更新开关未开启',
        settingEnabled: false,
      );
      return;
    }

    isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NON_ANDROID_PLATFORM',
        message: '当前平台不是 Android',
        settingEnabled: true,
        isAndroid: false,
      );
      return;
    }

    final weatherData = state.weatherData;
    hasWeatherData = weatherData != null;
    if (weatherData == null) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NO_WEATHER_DATA',
        message: '当前没有可用于实时更新的天气数据',
        settingEnabled: true,
        isAndroid: isAndroid,
        hasWeatherData: false,
      );
      return;
    }

    titlePreview = '${weatherData.location.name} ${weatherData.current.temp}°';

    final supported = await notificationServiceProvider
        .isAndroidLiveUpdateSupported();
    isSupported = supported;
    if (!supported) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'ANDROID_VERSION_UNSUPPORTED',
        message: '当前系统不支持实时更新通知（需 Android 16+）',
        settingEnabled: true,
        isAndroid: isAndroid,
        hasWeatherData: hasWeatherData,
        isSupported: false,
        titlePreview: titlePreview,
      );
      return;
    }

    final canPostPromoted = await notificationServiceProvider
        .canPostPromotedNotifications();
    hasPromotedPermission = canPostPromoted;
    if (!canPostPromoted) {
      await notificationServiceProvider.cancelAndroidLiveWeatherUpdate();
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'PROMOTED_PERMISSION_DENIED',
        message: '系统未允许应用发布 Promoted 实时更新通知',
        settingEnabled: true,
        isAndroid: isAndroid,
        hasWeatherData: hasWeatherData,
        isSupported: isSupported,
        promotedPermission: false,
        titlePreview: titlePreview,
      );
      return;
    }

    final hasPermission = await notificationServiceProvider
        .checkNotificationPermission();
    hasNotificationPermission = hasPermission;
    if (!hasPermission) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NOTIFICATION_PERMISSION_DENIED',
        message: '未授予通知权限',
        settingEnabled: true,
        isAndroid: isAndroid,
        hasWeatherData: hasWeatherData,
        isSupported: isSupported,
        notificationPermission: false,
        promotedPermission: hasPromotedPermission,
        titlePreview: titlePreview,
      );
      return;
    }

    final content =
        '${weatherData.current.text} · 体感${weatherData.current.feelsLike}° · ${_formatTime(weatherData.lastUpdated)} 更新';

    final result = await notificationServiceProvider
        .showAndroidLiveWeatherUpdateDetailed(
          title: titlePreview,
          content: content,
        );

    promotableCharacteristics = result.code == 'NOT_PROMOTABLE_CHARACTERISTICS'
        ? false
        : (result.success ? true : null);
    liveUpdateDiagnosticsService.record(
      scene: scene,
      success: result.success,
      code: result.code,
      message: result.message,
      settingEnabled: true,
      isAndroid: isAndroid,
      hasWeatherData: hasWeatherData,
      isSupported: isSupported,
      notificationPermission: hasNotificationPermission,
      promotedPermission: hasPromotedPermission,
      promotableCharacteristics: promotableCharacteristics,
      titlePreview: titlePreview,
    );
  }

  /// 获取预警级别文本
  ///
  /// [level]: 预警级别
  String _getSeverityText(String level) {
    switch (level) {
      case '红色':
        return '🔴 红色预警 - 极端天气';
      case '橙色':
        return '🟠 橙色预警 - 严重天气';
      case '黄色':
        return '🟡 黄色预警 - 较重天气';
      case '蓝色':
        return '🔵 蓝色预警 - 一般天气';
      default:
        return level;
    }
  }

  /// 截断文本
  ///
  /// [text]: 原始文本
  /// [maxLength]: 最大长度
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 刷新天气数据
  Future<void> refresh() async {
    final location = _ref.read(defaultCityProvider);
    if (location != null) {
      await loadWeather(location);
    }
  }

  /// 持久化天气数据缓存
  Future<void> _saveWeatherCache(String locationId, WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'weather_cache_$locationId';
      await prefs.setString(key, jsonEncode(data.toJson()));
      debugPrint('[WeatherCache] Saved cache for $locationId');
    } catch (e) {
      debugPrint('[WeatherCache] Save failed: $e');
    }
  }

  /// 清理已删除城市的孤儿缓存
  Future<void> _cleanupWeatherCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // 获取当前所有保存的城市ID
      final cityStore = await _ref.read(cityRepositoryProvider).loadStore();
      final currentCityIds = cityStore.cities.map((city) => city.id).toSet();

      // 扫描并删除孤儿缓存
      for (final key in keys) {
        if (key.startsWith('weather_cache_')) {
          final cityId = key.replaceFirst('weather_cache_', '');
          if (!currentCityIds.contains(cityId)) {
            await prefs.remove(key);
            debugPrint('[WeatherCache] Cleaned up orphaned cache: $key');
          }
        }
      }
    } catch (e) {
      debugPrint('[WeatherCache] Cleanup failed: $e');
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// 天气状态Provider
///
/// 提供全局天气状态管理
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((
  ref,
) {
  return WeatherNotifier(
    ref,
    ref.watch(qweatherServiceProvider),
    ref.watch(caiyunWeatherServiceProvider),
  );
});

/// 城市天气数据Provider
///
/// 为指定城市提供天气数据
/// [Location]: 城市位置信息
final weatherForCityProvider = FutureProvider.family<WeatherData?, Location>((
  ref,
  location,
) async {
  final service = ref.watch(qweatherServiceProvider);
  try {
    return await service.getFullWeatherData(location.id, location);
  } catch (_) {
    return null;
  }
});
