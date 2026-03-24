import 'package:flutter/foundation.dart';

/// 实时更新诊断记录
class LiveUpdateDiagnosticEntry {
  final DateTime timestamp;
  final String scene;
  final bool success;
  final String code;
  final String message;
  final bool? settingEnabled;
  final bool? isAndroid;
  final bool? hasWeatherData;
  final bool? isSupported;
  final bool? notificationPermission;
  final bool? promotedPermission;
  final bool? promotableCharacteristics;
  final String? titlePreview;

  const LiveUpdateDiagnosticEntry({
    required this.timestamp,
    required this.scene,
    required this.success,
    required this.code,
    required this.message,
    this.settingEnabled,
    this.isAndroid,
    this.hasWeatherData,
    this.isSupported,
    this.notificationPermission,
    this.promotedPermission,
    this.promotableCharacteristics,
    this.titlePreview,
  });
}

/// 实时更新诊断服务（仅 Debug 模式记录）
class LiveUpdateDiagnosticsService {
  static final LiveUpdateDiagnosticsService _instance =
      LiveUpdateDiagnosticsService._internal();

  factory LiveUpdateDiagnosticsService() => _instance;

  LiveUpdateDiagnosticsService._internal();

  static const int _maxEntries = 80;

  final ValueNotifier<List<LiveUpdateDiagnosticEntry>> entries =
      ValueNotifier<List<LiveUpdateDiagnosticEntry>>([]);

  void record({
    required String scene,
    required bool success,
    required String code,
    required String message,
    bool? settingEnabled,
    bool? isAndroid,
    bool? hasWeatherData,
    bool? isSupported,
    bool? notificationPermission,
    bool? promotedPermission,
    bool? promotableCharacteristics,
    String? titlePreview,
  }) {
    if (!kDebugMode) return;

    final next = [
      LiveUpdateDiagnosticEntry(
        timestamp: DateTime.now(),
        scene: scene,
        success: success,
        code: code,
        message: message,
        settingEnabled: settingEnabled,
        isAndroid: isAndroid,
        hasWeatherData: hasWeatherData,
        isSupported: isSupported,
        notificationPermission: notificationPermission,
        promotedPermission: promotedPermission,
        promotableCharacteristics: promotableCharacteristics,
        titlePreview: titlePreview,
      ),
      ...entries.value,
    ];

    entries.value = next.take(_maxEntries).toList();
  }

  void clear() {
    entries.value = [];
  }
}

final liveUpdateDiagnosticsService = LiveUpdateDiagnosticsService();
