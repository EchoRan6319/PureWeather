import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知服务类，用于管理应用的本地通知
class NotificationService {
  /// 单例实例
  static final NotificationService _instance = NotificationService._internal();
  
  /// 工厂构造函数
  factory NotificationService() => _instance;
  
  /// 私有构造函数
  NotificationService._internal();

  /// Flutter本地通知插件实例
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  
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
  static const String _keyNotificationPermissionRequested = 'notification_permission_requested';

  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化通知服务
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
  /// 
  /// 返回是否获得权限
  Future<bool> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await notifications
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

  /// 检查通知权限
  /// 
  /// 返回是否有权限
  Future<bool> checkNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
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
    await notifications.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
  }

  /// 创建通知渠道（Android）
  Future<void> createNotificationChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = notifications.resolvePlatformSpecificImplementation<
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

/// 通知服务的Provider
final notificationServiceProvider = NotificationService();
