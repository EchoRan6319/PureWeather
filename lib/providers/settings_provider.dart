import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 位置精度级别枚举
/// 
/// - district: 区县级别
/// - street: 街道级别
enum LocationAccuracyLevel { district, street }

/// 应用设置类
/// 
/// 管理应用的所有设置选项
class AppSettings {
  /// 是否启用预测性返回
  final bool predictiveBackEnabled;
  /// 是否启用通知
  final bool notificationsEnabled;
  /// 是否启用自动刷新
  final bool autoRefreshEnabled;
  /// 刷新间隔（分钟）
  final int refreshInterval;
  /// 温度单位
  final String temperatureUnit;
  /// 是否显示体感温度
  final bool showFeelsLike;
  /// 是否显示天气助手
  final bool showAIAssistant;
  /// 位置精度级别
  final LocationAccuracyLevel locationAccuracyLevel;
  /// 天气卡片顺序
  final List<String> weatherCardOrder;

  /// 构造函数
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

  /// 复制并更新设置
  /// 
  /// [predictiveBackEnabled]: 是否启用预测性返回
  /// [notificationsEnabled]: 是否启用通知
  /// [autoRefreshEnabled]: 是否启用自动刷新
  /// [refreshInterval]: 刷新间隔
  /// [temperatureUnit]: 温度单位
  /// [showFeelsLike]: 是否显示体感温度
  /// [showAIAssistant]: 是否显示天气助手
  /// [locationAccuracyLevel]: 位置精度级别
  /// [weatherCardOrder]: 天气卡片顺序
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

/// 设置状态管理类
/// 
/// 负责管理应用设置的加载、保存和更新
class SettingsNotifier extends StateNotifier<AppSettings> {
  /// 预测性返回设置键
  static const String _keyPredictiveBack = 'predictive_back_enabled';
  /// 通知设置键
  static const String _keyNotifications = 'notifications_enabled';
  /// 自动刷新设置键
  static const String _keyAutoRefresh = 'auto_refresh_enabled';
  /// 刷新间隔设置键
  static const String _keyRefreshInterval = 'refresh_interval';
  /// 温度单位设置键
  static const String _keyTemperatureUnit = 'temperature_unit';
  /// 显示体感温度设置键
  static const String _keyShowFeelsLike = 'show_feels_like';
  /// 显示天气助手设置键
  static const String _keyShowAIAssistant = 'show_ai_assistant';
  /// 位置精度级别设置键
  static const String _keyLocationAccuracyLevel = 'location_accuracy_level';
  /// 天气卡片顺序设置键
  static const String _keyWeatherCardOrder = 'weather_card_order';

  /// 构造函数
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  /// 从本地存储加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载位置精度级别
    final savedLevel = prefs.getString(_keyLocationAccuracyLevel);
    LocationAccuracyLevel accuracyLevel = LocationAccuracyLevel.district;
    if (savedLevel == 'street') {
      accuracyLevel = LocationAccuracyLevel.street;
    }

    // 加载天气卡片顺序
    final savedOrder = prefs.getStringList(_keyWeatherCardOrder);
    
    // 验证并修复天气卡片顺序
    const validOrder = ['hourly', 'daily', 'airQuality', 'details'];
    List<String> validatedOrder;
    
    if (savedOrder == null) {
      validatedOrder = validOrder;
    } else {
      // 检查保存的顺序是否有效
      final hasAllValidCards = savedOrder.every((card) => validOrder.contains(card));
      final hasCorrectLength = savedOrder.length == validOrder.length;
      
      if (hasAllValidCards && hasCorrectLength) {
        validatedOrder = savedOrder;
      } else {
        // 如果顺序无效，使用默认顺序
        validatedOrder = validOrder;
        // 保存修复后的顺序
        await prefs.setStringList(_keyWeatherCardOrder, validatedOrder);
      }
    }

    // 更新状态
    state = AppSettings(
      predictiveBackEnabled: prefs.getBool(_keyPredictiveBack) ?? false,
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      autoRefreshEnabled: prefs.getBool(_keyAutoRefresh) ?? true,
      refreshInterval: prefs.getInt(_keyRefreshInterval) ?? 30,
      temperatureUnit: prefs.getString(_keyTemperatureUnit) ?? 'celsius',
      showFeelsLike: prefs.getBool(_keyShowFeelsLike) ?? true,
      showAIAssistant: prefs.getBool(_keyShowAIAssistant) ?? true,
      locationAccuracyLevel: accuracyLevel,
      weatherCardOrder: validatedOrder,
    );
  }

  /// 设置是否启用预测性返回
  /// 
  /// [value]: 是否启用
  Future<void> setPredictiveBackEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPredictiveBack, value);
    state = state.copyWith(predictiveBackEnabled: value);
  }

  /// 设置是否启用通知
  /// 
  /// [value]: 是否启用
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  /// 设置是否启用自动刷新
  /// 
  /// [value]: 是否启用
  Future<void> setAutoRefreshEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRefresh, value);
    state = state.copyWith(autoRefreshEnabled: value);
  }

  /// 设置刷新间隔
  /// 
  /// [value]: 刷新间隔（分钟）
  Future<void> setRefreshInterval(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRefreshInterval, value);
    state = state.copyWith(refreshInterval: value);
  }

  /// 设置温度单位
  /// 
  /// [value]: 温度单位
  Future<void> setTemperatureUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTemperatureUnit, value);
    state = state.copyWith(temperatureUnit: value);
  }

  /// 设置是否显示体感温度
  /// 
  /// [value]: 是否显示
  Future<void> setShowFeelsLike(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFeelsLike, value);
    state = state.copyWith(showFeelsLike: value);
  }

  /// 设置是否显示天气助手
  /// 
  /// [value]: 是否显示
  Future<void> setShowAIAssistant(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowAIAssistant, value);
    state = state.copyWith(showAIAssistant: value);
  }

  /// 设置位置精度级别
  /// 
  /// [value]: 位置精度级别
  Future<void> setLocationAccuracyLevel(LocationAccuracyLevel value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLocationAccuracyLevel,
      value == LocationAccuracyLevel.street ? 'street' : 'district',
    );
    state = state.copyWith(locationAccuracyLevel: value);
  }

  /// 设置天气卡片顺序
  /// 
  /// [value]: 天气卡片顺序
  Future<void> setWeatherCardOrder(List<String> value) async {
    // 验证顺序是否有效
    const validOrder = ['hourly', 'daily', 'airQuality', 'details'];
    final hasAllValidCards = value.every((card) => validOrder.contains(card));
    final hasCorrectLength = value.length == validOrder.length;
    
    List<String> validatedOrder;
    if (hasAllValidCards && hasCorrectLength) {
      validatedOrder = value;
    } else {
      validatedOrder = validOrder;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWeatherCardOrder, validatedOrder);
    state = state.copyWith(weatherCardOrder: validatedOrder);
  }
}

/// 设置Provider
/// 
/// 提供应用设置的状态管理
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
