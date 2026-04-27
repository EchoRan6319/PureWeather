import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../services/scheduled_broadcast_service.dart';

/// 定时时间类，用于表示定时播报的时间设置
class ScheduledTime {
  /// 小时
  final int hour;
  
  /// 分钟
  final int minute;
  
  /// 是否启用
  final bool enabled;

  /// 创建定时时间实例
  /// 
  /// [hour] 小时
  /// [minute] 分钟
  /// [enabled] 是否启用，默认为true
  const ScheduledTime({
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  /// 从JSON创建定时时间实例
  /// 
  /// [json] JSON数据
  factory ScheduledTime.fromJson(Map<String, dynamic> json) {
    return ScheduledTime(
      hour: json['hour'] as int? ?? 7,
      minute: json['minute'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
      };

  /// 创建定时时间的副本，可选择性修改部分属性
  /// 
  /// [hour] 小时
  /// [minute] 分钟
  /// [enabled] 是否启用
  /// 
  /// 返回修改后的ScheduledTime实例
  ScheduledTime copyWith({
    int? hour,
    int? minute,
    bool? enabled,
  }) {
    return ScheduledTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 格式化时间字符串，格式为HH:MM
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 显示名称
  /// 
  /// - 7:00 显示为"早上播报"
  /// - 20:00 显示为"晚间播报"
  /// - 其他时间显示为格式化时间
  String get displayName {
    if (hour == 7 && minute == 0) return AppLocalizations.tr('早上播报');
    if (hour == 20 && minute == 0) return AppLocalizations.tr('晚间播报');
    return formattedTime;
  }
}

/// 定时播报设置类，包含定时播报的所有配置
class ScheduledBroadcastSettings {
  /// 是否启用定时播报
  final bool enabled;
  
  /// 早上播报时间
  final ScheduledTime morningTime;
  
  /// 晚间播报时间
  final ScheduledTime eveningTime;
  
  /// 是否包含空气质量信息
  final bool includeAirQuality;
  
  /// 是否包含风力信息
  final bool includeWindInfo;

  /// 创建定时播报设置实例
  /// 
  /// [enabled] 是否启用定时播报，默认为true
  /// [morningTime] 早上播报时间，默认为7:00
  /// [eveningTime] 晚间播报时间，默认为20:00
  /// [includeAirQuality] 是否包含空气质量信息，默认为true
  /// [includeWindInfo] 是否包含风力信息，默认为true
  const ScheduledBroadcastSettings({
    this.enabled = true,
    this.morningTime = const ScheduledTime(hour: 7, minute: 0),
    this.eveningTime = const ScheduledTime(hour: 20, minute: 0),
    this.includeAirQuality = true,
    this.includeWindInfo = true,
  });

  /// 从JSON创建定时播报设置实例
  /// 
  /// [json] JSON数据
  factory ScheduledBroadcastSettings.fromJson(Map<String, dynamic> json) {
    return ScheduledBroadcastSettings(
      enabled: json['enabled'] as bool? ?? true,
      morningTime: json['morningTime'] != null
          ? ScheduledTime.fromJson(json['morningTime'] as Map<String, dynamic>)
          : const ScheduledTime(hour: 7, minute: 0),
      eveningTime: json['eveningTime'] != null
          ? ScheduledTime.fromJson(json['eveningTime'] as Map<String, dynamic>)
          : const ScheduledTime(hour: 20, minute: 0),
      includeAirQuality: json['includeAirQuality'] as bool? ?? true,
      includeWindInfo: json['includeWindInfo'] as bool? ?? true,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'morningTime': morningTime.toJson(),
        'eveningTime': eveningTime.toJson(),
        'includeAirQuality': includeAirQuality,
        'includeWindInfo': includeWindInfo,
      };

  /// 创建定时播报设置的副本，可选择性修改部分属性
  /// 
  /// [enabled] 是否启用定时播报
  /// [morningTime] 早上播报时间
  /// [eveningTime] 晚间播报时间
  /// [includeAirQuality] 是否包含空气质量信息
  /// [includeWindInfo] 是否包含风力信息
  /// 
  /// 返回修改后的ScheduledBroadcastSettings实例
  ScheduledBroadcastSettings copyWith({
    bool? enabled,
    ScheduledTime? morningTime,
    ScheduledTime? eveningTime,
    bool? includeAirQuality,
    bool? includeWindInfo,
  }) {
    return ScheduledBroadcastSettings(
      enabled: enabled ?? this.enabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      includeAirQuality: includeAirQuality ?? this.includeAirQuality,
      includeWindInfo: includeWindInfo ?? this.includeWindInfo,
    );
  }
}

/// 定时播报通知器，管理定时播报设置的状态
class ScheduledBroadcastNotifier
    extends StateNotifier<ScheduledBroadcastSettings> {
  /// 存储键
  static const String _key = 'scheduled_broadcast_settings';

  /// 创建定时播报通知器实例
  ScheduledBroadcastNotifier() : super(const ScheduledBroadcastSettings()) {
    _loadSettings();
  }

  /// 从SharedPreferences加载定时播报设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = ScheduledBroadcastSettings.fromJson(json);
      } catch (_) {}
    }
  }

  /// 保存定时播报设置到SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
    // 同步到服务层，以便 Windows 补偿逻辑使用最新的设置
    await scheduledBroadcastServiceProvider.scheduleBroadcasts(state);
  }

  /// 设置是否启用定时播报
  /// 
  /// [value] 是否启用
  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _saveSettings();
  }

  /// 设置早上播报时间
  /// 
  /// [time] 早上播报时间
  Future<void> setMorningTime(ScheduledTime time) async {
    state = state.copyWith(morningTime: time);
    await _saveSettings();
  }

  /// 设置晚间播报时间
  /// 
  /// [time] 晚间播报时间
  Future<void> setEveningTime(ScheduledTime time) async {
    state = state.copyWith(eveningTime: time);
    await _saveSettings();
  }

  /// 设置是否包含空气质量信息
  /// 
  /// [value] 是否包含
  Future<void> setIncludeAirQuality(bool value) async {
    state = state.copyWith(includeAirQuality: value);
    await _saveSettings();
  }

  /// 设置是否包含风力信息
  /// 
  /// [value] 是否包含
  Future<void> setIncludeWindInfo(bool value) async {
    state = state.copyWith(includeWindInfo: value);
    await _saveSettings();
  }
}

/// 定时播报设置的Provider
final scheduledBroadcastProvider = StateNotifierProvider<
    ScheduledBroadcastNotifier, ScheduledBroadcastSettings>((ref) {
  return ScheduledBroadcastNotifier();
});
