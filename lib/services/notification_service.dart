import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _channelId = 'weather_alerts';
  static const String _channelName = '天气预警';
  static const String _channelDescription = '接收极端天气预警通知';
  static const String _keyFirstRun = 'first_run_completed';
  static const String _keyNotificationPermissionRequested = 'notification_permission_requested';

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  Future<bool> checkNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return false;
  }

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  Future<void> markFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }

  Future<bool> hasRequestedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationPermissionRequested) ?? false;
  }

  Future<void> markNotificationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationPermissionRequested, true);
  }

  Future<void> showWeatherAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
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

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

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

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> createNotificationChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
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
}

final notificationServiceProvider = NotificationService();
