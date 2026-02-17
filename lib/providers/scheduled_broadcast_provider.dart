import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledTime {
  final int hour;
  final int minute;
  final bool enabled;

  const ScheduledTime({
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  factory ScheduledTime.fromJson(Map<String, dynamic> json) {
    return ScheduledTime(
      hour: json['hour'] as int? ?? 7,
      minute: json['minute'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
      };

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

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get displayName {
    if (hour == 7 && minute == 0) return '早上播报';
    if (hour == 20 && minute == 0) return '晚间播报';
    return formattedTime;
  }
}

class ScheduledBroadcastSettings {
  final bool enabled;
  final ScheduledTime morningTime;
  final ScheduledTime eveningTime;
  final bool includeAirQuality;
  final bool includeWindInfo;

  const ScheduledBroadcastSettings({
    this.enabled = true,
    this.morningTime = const ScheduledTime(hour: 7, minute: 0),
    this.eveningTime = const ScheduledTime(hour: 20, minute: 0),
    this.includeAirQuality = true,
    this.includeWindInfo = true,
  });

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

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'morningTime': morningTime.toJson(),
        'eveningTime': eveningTime.toJson(),
        'includeAirQuality': includeAirQuality,
        'includeWindInfo': includeWindInfo,
      };

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

class ScheduledBroadcastNotifier
    extends StateNotifier<ScheduledBroadcastSettings> {
  static const String _key = 'scheduled_broadcast_settings';

  ScheduledBroadcastNotifier() : super(const ScheduledBroadcastSettings()) {
    _loadSettings();
  }

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

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _saveSettings();
  }

  Future<void> setMorningTime(ScheduledTime time) async {
    state = state.copyWith(morningTime: time);
    await _saveSettings();
  }

  Future<void> setEveningTime(ScheduledTime time) async {
    state = state.copyWith(eveningTime: time);
    await _saveSettings();
  }

  Future<void> setIncludeAirQuality(bool value) async {
    state = state.copyWith(includeAirQuality: value);
    await _saveSettings();
  }

  Future<void> setIncludeWindInfo(bool value) async {
    state = state.copyWith(includeWindInfo: value);
    await _saveSettings();
  }
}

final scheduledBroadcastProvider = StateNotifierProvider<
    ScheduledBroadcastNotifier, ScheduledBroadcastSettings>((ref) {
  return ScheduledBroadcastNotifier();
});
