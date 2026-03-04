import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocationAccuracyLevel { district, street }

class AppSettings {
  final bool predictiveBackEnabled;
  final bool notificationsEnabled;
  final bool autoRefreshEnabled;
  final int refreshInterval;
  final String temperatureUnit;
  final bool showFeelsLike;
  final bool showAIAssistant;
  final LocationAccuracyLevel locationAccuracyLevel;
  final List<String> weatherCardOrder;

  const AppSettings({
    this.predictiveBackEnabled = false,
    this.notificationsEnabled = true,
    this.autoRefreshEnabled = true,
    this.refreshInterval = 30,
    this.temperatureUnit = 'celsius',
    this.showFeelsLike = true,
    this.showAIAssistant = true,
    this.locationAccuracyLevel = LocationAccuracyLevel.district,
    this.weatherCardOrder = const [
      'hourly',
      'daily',
      'airQuality',
      'details',
    ],
  });

  AppSettings copyWith({
    bool? predictiveBackEnabled,
    bool? notificationsEnabled,
    bool? autoRefreshEnabled,
    int? refreshInterval,
    String? temperatureUnit,
    bool? showFeelsLike,
    bool? showAIAssistant,
    LocationAccuracyLevel? locationAccuracyLevel,
    List<String>? weatherCardOrder,
  }) {
    return AppSettings(
      predictiveBackEnabled:
          predictiveBackEnabled ?? this.predictiveBackEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      showFeelsLike: showFeelsLike ?? this.showFeelsLike,
      showAIAssistant: showAIAssistant ?? this.showAIAssistant,
      locationAccuracyLevel:
          locationAccuracyLevel ?? this.locationAccuracyLevel,
      weatherCardOrder: weatherCardOrder ?? this.weatherCardOrder,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _keyPredictiveBack = 'predictive_back_enabled';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyAutoRefresh = 'auto_refresh_enabled';
  static const String _keyRefreshInterval = 'refresh_interval';
  static const String _keyTemperatureUnit = 'temperature_unit';
  static const String _keyShowFeelsLike = 'show_feels_like';
  static const String _keyShowAIAssistant = 'show_ai_assistant';
  static const String _keyLocationAccuracyLevel = 'location_accuracy_level';
  static const String _keyWeatherCardOrder = 'weather_card_order';

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLevel = prefs.getString(_keyLocationAccuracyLevel);
    LocationAccuracyLevel accuracyLevel = LocationAccuracyLevel.district;
    if (savedLevel == 'street') {
      accuracyLevel = LocationAccuracyLevel.street;
    }

    final savedOrder = prefs.getStringList(_keyWeatherCardOrder);

    state = AppSettings(
      predictiveBackEnabled: prefs.getBool(_keyPredictiveBack) ?? false,
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      autoRefreshEnabled: prefs.getBool(_keyAutoRefresh) ?? true,
      refreshInterval: prefs.getInt(_keyRefreshInterval) ?? 30,
      temperatureUnit: prefs.getString(_keyTemperatureUnit) ?? 'celsius',
      showFeelsLike: prefs.getBool(_keyShowFeelsLike) ?? true,
      showAIAssistant: prefs.getBool(_keyShowAIAssistant) ?? true,
      locationAccuracyLevel: accuracyLevel,
      weatherCardOrder:
          savedOrder ?? const ['hourly', 'daily', 'airQuality', 'details'],
    );
  }

  Future<void> setPredictiveBackEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPredictiveBack, value);
    state = state.copyWith(predictiveBackEnabled: value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setAutoRefreshEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRefresh, value);
    state = state.copyWith(autoRefreshEnabled: value);
  }

  Future<void> setRefreshInterval(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRefreshInterval, value);
    state = state.copyWith(refreshInterval: value);
  }

  Future<void> setTemperatureUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTemperatureUnit, value);
    state = state.copyWith(temperatureUnit: value);
  }

  Future<void> setShowFeelsLike(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFeelsLike, value);
    state = state.copyWith(showFeelsLike: value);
  }

  Future<void> setShowAIAssistant(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowAIAssistant, value);
    state = state.copyWith(showAIAssistant: value);
  }

  Future<void> setLocationAccuracyLevel(LocationAccuracyLevel value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLocationAccuracyLevel,
      value == LocationAccuracyLevel.street ? 'street' : 'district',
    );
    state = state.copyWith(locationAccuracyLevel: value);
  }

  Future<void> setWeatherCardOrder(List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWeatherCardOrder, value);
    state = state.copyWith(weatherCardOrder: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
