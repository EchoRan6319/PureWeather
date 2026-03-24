import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 实时更新推送结果
class LiveUpdatePostResult {
  final bool success;
  final String code;
  final String message;

  const LiveUpdatePostResult({
    required this.success,
    required this.code,
    required this.message,
  });
}

/// 通知服务类，用于管理应用的本地通知
class NotificationService {
  /// 单例实例
  static final NotificationService _instance = NotificationService._internal();

  /// 工厂构造函数
  factory NotificationService() => _instance;

  /// 私有构造函数
  NotificationService._internal();

  /// Flutter本地通知插件实例
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  /// Android 实时更新通知 MethodChannel
  static const MethodChannel _liveUpdateChannel = MethodChannel(
    'com.echoran.pureweather/live_update',
  );

  /// 是否已初始化
  bool _isInitialized = false;

  /// 通知渠道ID
  static const String _channelId = 'weather_alerts';

  /// 通知渠道名称
  static const String _channelName = '天气预警';

  /// 通知渠道描述
  static const String _channelDescription = '接收极端天气预警通知';

  /// 首次运行标记键
  static const String _keyFirstRun = 'first_run_completed';

  /// 通知权限请求标记键
  static const String _keyNotificationPermissionRequested =
      'notification_permission_requested';

  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      linux: linuxSettings,
    );

    await notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// 通知点击回调
  ///
  /// [response] 通知响应
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // 请求精准闹钟权限（Android 12+）
      final canScheduleExact =
          await plugin?.requestExactAlarmsPermission() ?? false;
      debugPrint('[Notification] Can schedule exact alarms: $canScheduleExact');

      // 请求通知权限（Android 13+）
      final isGranted = await plugin?.requestNotificationsPermission() ?? false;
      return isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// 检查通知权限
  ///
  /// 返回是否有权限
  Future<bool> checkNotificationPermission() async {
    if (kIsWeb) {
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return false;
  }

  /// 检查是否首次运行
  ///
  /// 返回是否首次运行
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  /// 标记首次运行已完成
  Future<void> markFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }

  /// 检查是否已请求过通知权限
  ///
  /// 返回是否已请求过
  Future<bool> hasRequestedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationPermissionRequested) ?? false;
  }

  /// 标记已请求过通知权限
  Future<void> markNotificationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationPermissionRequested, true);
  }

  /// 显示天气预警通知
  ///
  /// [id] 通知ID
  /// [title] 通知标题
  /// [body] 通知内容
  /// [payload] 通知负载
  Future<void> showWeatherAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (!_isInitialized) {
      await initialize();
    }

    final hasPermission = await checkNotificationPermission();
    if (!hasPermission) {
      debugPrint('Notification permission not granted');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// 显示天气预警通知
  ///
  /// [alertType] 预警类型
  /// [severity] 严重程度
  /// [description] 预警描述
  Future<void> showWeatherWarningAlert({
    required String alertType,
    required String severity,
    required String description,
  }) async {
    final title = '⚠️ $alertType';
    final body = '$severity\n$description';

    await showWeatherAlert(
      id: alertType.hashCode,
      title: title,
      body: body,
      payload: 'weather_alert',
    );
  }

  /// 取消指定ID的通知
  ///
  /// [id] 通知ID
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) {
      return;
    }
    await notifications.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      return;
    }
    await notifications.cancelAll();
  }

  /// 创建通知渠道（Android）
  Future<void> createNotificationChannel() async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  /// 检查 Android 实时更新通知是否受支持（Android 16+）
  Future<bool> isAndroidLiveUpdateSupported() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final supported = await _liveUpdateChannel.invokeMethod<bool>(
        'isSupported',
      );
      return supported ?? false;
    } catch (e) {
      debugPrint('[LiveUpdate] Support check failed: $e');
      return false;
    }
  }

  /// 是否允许发布 promoted 实时更新通知（Android 16+）
  Future<bool> canPostPromotedNotifications() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final allowed = await _liveUpdateChannel.invokeMethod<bool>(
        'canPostPromotedNotifications',
      );
      return allowed ?? false;
    } catch (e) {
      debugPrint('[LiveUpdate] canPostPromotedNotifications failed: $e');
      return false;
    }
  }

  /// 打开 promoted 实时更新通知系统设置页（Android 16+）
  Future<bool> openPromotedNotificationSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final opened = await _liveUpdateChannel.invokeMethod<bool>(
        'openPromotedNotificationSettings',
      );
      return opened ?? false;
    } catch (e) {
      debugPrint('[LiveUpdate] openPromotedNotificationSettings failed: $e');
      return false;
    }
  }

  /// 显示/更新 Android 实时更新通知
  Future<LiveUpdatePostResult> showAndroidLiveWeatherUpdateDetailed({
    required String title,
    required String content,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const LiveUpdatePostResult(
        success: false,
        code: 'NON_ANDROID_PLATFORM',
        message: '当前平台不是 Android',
      );
    }
    if (!await checkNotificationPermission()) {
      return const LiveUpdatePostResult(
        success: false,
        code: 'NOTIFICATION_PERMISSION_DENIED',
        message: '未授予通知权限',
      );
    }
    try {
      final raw = await _liveUpdateChannel.invokeMethod<dynamic>(
        'showWeatherLiveUpdate',
        {'title': title, 'content': content},
      );

      if (raw is Map) {
        final success = raw['success'] == true;
        final code = (raw['code'] ?? (success ? 'POSTED' : 'UNKNOWN_FAILURE'))
            .toString();
        final message = (raw['message'] ?? '').toString();
        return LiveUpdatePostResult(
          success: success,
          code: code,
          message: message,
        );
      }

      final success = raw == true;
      return LiveUpdatePostResult(
        success: success,
        code: success ? 'POSTED' : 'UNKNOWN_FAILURE',
        message: success ? '实时更新通知发送成功' : '实时更新通知发送失败',
      );
    } catch (e) {
      debugPrint('[LiveUpdate] Show failed: $e');
      return LiveUpdatePostResult(
        success: false,
        code: 'CHANNEL_EXCEPTION',
        message: '通道调用异常: $e',
      );
    }
  }

  /// 显示/更新 Android 实时更新通知
  Future<bool> showAndroidLiveWeatherUpdate({
    required String title,
    required String content,
  }) async {
    final result = await showAndroidLiveWeatherUpdateDetailed(
      title: title,
      content: content,
    );
    return result.success;
  }

  /// 调度 Android 实时更新通知（到指定时间触发）
  Future<LiveUpdatePostResult> scheduleAndroidLiveWeatherUpdate({
    required int id,
    required DateTime triggerAt,
    required String title,
    required String content,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const LiveUpdatePostResult(
        success: false,
        code: 'NON_ANDROID_PLATFORM',
        message: '当前平台不是 Android',
      );
    }
    try {
      final raw = await _liveUpdateChannel
          .invokeMethod<dynamic>('scheduleLiveUpdate', {
            'id': id,
            'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
            'title': title,
            'content': content,
          });

      if (raw is Map) {
        final success = raw['success'] == true;
        final code =
            (raw['code'] ?? (success ? 'SCHEDULED' : 'UNKNOWN_FAILURE'))
                .toString();
        final message = (raw['message'] ?? '').toString();
        return LiveUpdatePostResult(
          success: success,
          code: code,
          message: message,
        );
      }
      return const LiveUpdatePostResult(
        success: false,
        code: 'INVALID_NATIVE_RESPONSE',
        message: '原生返回结果格式无效',
      );
    } catch (e) {
      return LiveUpdatePostResult(
        success: false,
        code: 'CHANNEL_EXCEPTION',
        message: '调度实时更新通知异常: $e',
      );
    }
  }

  /// 取消已调度的 Android 实时更新通知
  Future<void> cancelScheduledAndroidLiveWeatherUpdate(int id) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _liveUpdateChannel.invokeMethod<bool>('cancelScheduledLiveUpdate', {
        'id': id,
      });
    } catch (e) {
      debugPrint('[LiveUpdate] cancelScheduledLiveUpdate failed: $e');
    }
  }

  /// 取消 Android 实时更新通知
  Future<void> cancelAndroidLiveWeatherUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _liveUpdateChannel.invokeMethod<void>('cancelWeatherLiveUpdate');
    } catch (e) {
      debugPrint('[LiveUpdate] Cancel failed: $e');
    }
  }
}

/// 通知服务的Provider
final notificationServiceProvider = NotificationService();
