import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../services/qweather_service.dart';
import '../services/caiyun_service.dart';
import '../services/notification_service.dart';
import 'city_provider.dart';
import 'settings_provider.dart';

enum WeatherLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class WeatherState {
  final WeatherLoadingState loadingState;
  final WeatherData? weatherData;
  final AirQuality? airQuality;
  final CaiyunMinuteRain? minuteRain;
  final String? errorMessage;

  const WeatherState({
    this.loadingState = WeatherLoadingState.initial,
    this.weatherData,
    this.airQuality,
    this.minuteRain,
    this.errorMessage,
  });

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

  bool get isLoading => loadingState == WeatherLoadingState.loading;
  bool get hasData => weatherData != null;
  bool get hasError => errorMessage != null;
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final QWeatherService _qweatherService;
  final CaiyunWeatherService _caiyunService;
  final Ref _ref;
  final Set<String> _shownAlertIds = {};

  WeatherNotifier(this._ref, this._qweatherService, this._caiyunService)
      : super(const WeatherState());

  Future<void> loadWeather(Location location) async {
    state = state.copyWith(
      loadingState: WeatherLoadingState.loading,
      clearError: true,
    );

    try {
      final results = await Future.wait([
        _qweatherService.getFullWeatherData(location.id, location),
        _qweatherService.getAirQuality(location.id),
        _caiyunService.getMinuteRain(location.lat, location.lon),
      ]);

      final weatherData = results[0] as WeatherData;
      
      state = WeatherState(
        loadingState: WeatherLoadingState.loaded,
        weatherData: weatherData,
        airQuality: results[1] as AirQuality?,
        minuteRain: results[2] as CaiyunMinuteRain?,
      );
      
      await _checkAndSendAlertNotifications(weatherData.alerts);
    } catch (e) {
      state = state.copyWith(
        loadingState: WeatherLoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }

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

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<void> refresh() async {
    final location = _ref.read(defaultCityProvider);
    if (location != null) {
      await loadWeather(location);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(
    ref,
    ref.watch(qweatherServiceProvider),
    ref.watch(caiyunWeatherServiceProvider),
  );
});

final weatherForCityProvider =
    FutureProvider.family<WeatherData?, Location>((ref, location) async {
  final service = ref.watch(qweatherServiceProvider);
  try {
    return await service.getFullWeatherData(location.id, location);
  } catch (_) {
    return null;
  }
});
