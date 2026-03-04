import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../services/qweather_service.dart';
import '../services/caiyun_service.dart';
import '../services/notification_service.dart';
import 'city_provider.dart';
import 'settings_provider.dart';

/// 天气加载状态枚举
/// 
/// - initial: 初始状态
/// - loading: 加载中
/// - loaded: 加载完成
/// - error: 加载失败
enum WeatherLoadingState {
  initial,
  loading,
  loaded,
  error,
}

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
  
  /// 错误信息
  final String? errorMessage;

  /// 构造函数
  const WeatherState({
    this.loadingState = WeatherLoadingState.initial,
    this.weatherData,
    this.airQuality,
    this.minuteRain,
    this.errorMessage,
  });

  /// 复制并更新状态
  /// 
  /// [loadingState]: 新的加载状态
  /// [weatherData]: 新的天气数据
  /// [airQuality]: 新的空气质量数据
  /// [minuteRain]: 新的分钟级降雨预报
  /// [errorMessage]: 新的错误信息
  /// [clearError]: 是否清除错误信息
  /// [clearWeather]: 是否清除天气数据
  WeatherState copyWith({
    WeatherLoadingState? loadingState,
    WeatherData? weatherData,
    AirQuality? airQuality,
    CaiyunMinuteRain? minuteRain,
    String? errorMessage,
    bool clearError = false,
    bool clearWeather = false,
  }) {
    return WeatherState(
      loadingState: loadingState ?? this.loadingState,
      weatherData: clearWeather ? null : (weatherData ?? this.weatherData),
      airQuality: clearWeather ? null : (airQuality ?? this.airQuality),
      minuteRain: clearWeather ? null : (minuteRain ?? this.minuteRain),
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
      final weatherData = await _qweatherService.getFullWeatherData(location.id, location);
      
      // 2. 尝试获取辅助数据，但不让它们阻塞核心数据
      AirQuality? airQuality;
      try {
        airQuality = await _qweatherService.getAirQuality(location.id);
      } catch (e) {
        debugPrint('加载空气质量失败: $e');
      }

      CaiyunMinuteRain? minuteRain;
      try {
        minuteRain = await _caiyunService.getMinuteRain(location.lat, location.lon);
      } catch (e) {
        debugPrint('加载彩云天气失败: $e');
      }

      // 更新状态为加载完成
      state = WeatherState(
        loadingState: WeatherLoadingState.loaded,
        weatherData: weatherData,
        airQuality: airQuality,
        minuteRain: minuteRain,
      );
      
      // 检查并发送天气预警通知
      await _checkAndSendAlertNotifications(weatherData.alerts);
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
  Future<void> _checkAndSendAlertNotifications(List<WeatherAlert> alerts) async {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;
    
    final hasPermission = await notificationServiceProvider.checkNotificationPermission();
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

  /// 刷新天气数据
  Future<void> refresh() async {
    final location = _ref.read(defaultCityProvider);
    if (location != null) {
      await loadWeather(location);
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
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
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
final weatherForCityProvider =
    FutureProvider.family<WeatherData?, Location>((ref, location) async {
  final service = ref.watch(qweatherServiceProvider);
  try {
    return await service.getFullWeatherData(location.id, location);
  } catch (_) {
    return null;
  }
});
