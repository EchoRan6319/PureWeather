import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'qweather_service.dart';
import 'notification_service.dart';
import 'live_update_diagnostics_service.dart';
import '../providers/city_repository.dart';
import '../providers/scheduled_broadcast_provider.dart';
import '../models/weather_models.dart';

/// 定时播报服务类，用于管理天气定时播报功能
class ScheduledBroadcastService {
  /// 单例实例
  static final ScheduledBroadcastService _instance =
      ScheduledBroadcastService._internal();

  /// 工厂构造函数
  factory ScheduledBroadcastService() => _instance;

  /// 私有构造函数
  ScheduledBroadcastService._internal() {
    _startPulseTimer();
  }

  /// 天气服务实例
  final QWeatherService _weatherService = QWeatherService();

  /// 定时器，用于桌面端补偿
  Timer? _pulseTimer;

  /// 最后一次触发检查的小时，避免重复触发
  int _lastCheckHour = -1;

  /// 缓存当前设置，以便在准点检查时使用
  ScheduledBroadcastSettings? _currentSettings;

  /// 获取通知插件实例
  FlutterLocalNotificationsPlugin get _notifications =>
      notificationServiceProvider.notifications;

  /// 早上通知ID
  static const int _morningNotificationId = 10001;

  /// 晚上通知ID
  static const int _eveningNotificationId = 10002;

  /// 通知渠道ID
  static const String _channelId = 'scheduled_broadcast';

  /// 通知渠道名称
  static const String _channelName = '定时播报';

  /// 通知渠道描述
  static const String _channelDescription = '定时推送天气信息';

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化定时播报服务
  Future<void> initialize() async {
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }
    if (_isInitialized) return;
    await notificationServiceProvider.initialize();

    try {
      tz_data.initializeTimeZones();
      // 动态获取系统当前时区，并处理可能的平台名称不匹配问题
      final now = DateTime.now();
      final String timeZoneName = now.timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('[ScheduledBroadcast] Timezone initialized: $timeZoneName');
      } catch (_) {
        // 如果系统时区名无法被 timezone 库识别，默认回退到上海
        const fallback = 'Asia/Shanghai';
        tz.setLocalLocation(tz.getLocation(fallback));
        debugPrint('[ScheduledBroadcast] Timezone fallback to: $fallback');
      }
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Error initializing timezone: $e');
      // Fallback to UTC if local fails, or handle appropriately
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
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

    _isInitialized = true;
  }

  /// 调度定时播报
  ///
  /// [settings] 定时播报设置
  Future<void> scheduleBroadcasts(ScheduledBroadcastSettings settings) async {
    if (kIsWeb) {
      return;
    }
    await initialize();
    _currentSettings = settings; // 更新本地缓存的设置，供 pulse timer 使用
    await cancelAllScheduledBroadcasts();

    debugPrint('[ScheduledBroadcast] scheduleBroadcasts called');
    debugPrint('[ScheduledBroadcast] Settings enabled: ${settings.enabled}');
    debugPrint(
      '[ScheduledBroadcast] Morning time: ${settings.morningTime.formattedTime}, enabled: ${settings.morningTime.enabled}',
    );
    debugPrint(
      '[ScheduledBroadcast] Evening time: ${settings.eveningTime.formattedTime}, enabled: ${settings.eveningTime.enabled}',
    );

    if (!settings.enabled) {
      debugPrint('[ScheduledBroadcast] Broadcasts disabled, skipping');
      return;
    }

    final hasPermission = await notificationServiceProvider
        .checkNotificationPermission();
    if (!hasPermission) {
      debugPrint('[ScheduledBroadcast] Notification permission not granted');
      return;
    }

    // 检查电池优化
    await _checkBatteryOptimization();

    if (settings.morningTime.enabled) {
      await _scheduleMorningBroadcast(settings);
    } else {
      debugPrint('[ScheduledBroadcast] Morning broadcast disabled');
    }

    if (settings.eveningTime.enabled) {
      await _scheduleEveningBroadcast(settings);
    } else {
      debugPrint('[ScheduledBroadcast] Evening broadcast disabled');
    }
  }

  /// 调度早上播报
  ///
  /// [settings] 定时播报设置
  Future<void> _scheduleMorningBroadcast(
    ScheduledBroadcastSettings settings,
  ) async {
    if (kIsWeb) {
      return;
    }

    // 提前获取天气数据，将内容“硬编码”到系统调度中
    String body = '点击查看今日天气详情';
    try {
      final weatherData = await _fetchDefaultCityWeather();
      body = _buildMorningContent(weatherData, settings);
      if (body.isEmpty) body = '今日天气：${weatherData.current.text}';

      // 如果是用缓存数据，加上标记
      final isFromNetwork = await _isDataFresh(weatherData);
      if (!isFromNetwork) body += ' (来自本地缓存)';
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Morning pre-fetch failed: $e');
    }

    final scheduledDate = _nextInstanceOfTime(
      settings.morningTime.hour,
      settings.morningTime.minute,
    );

    if (scheduledDate == null) return;

    final scheduledAsLiveUpdate = await _tryScheduleLiveUpdateAt(
      scene: 'scheduled_morning_plan',
      id: _morningNotificationId,
      triggerAt: DateTime.fromMillisecondsSinceEpoch(
        scheduledDate.millisecondsSinceEpoch,
      ),
      title: '早安天气',
      body: body,
    );
    if (scheduledAsLiveUpdate) {
      debugPrint(
        '[ScheduledBroadcast] Morning live update scheduled successfully',
      );
      return;
    }

    debugPrint(
      '[ScheduledBroadcast] Scheduling morning broadcast for: $scheduledDate',
    );

    await _notifications.zonedSchedule(
      _morningNotificationId,
      '早安天气',
      body,
      scheduledDate,
      await _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning_broadcast',
    );

    debugPrint('[ScheduledBroadcast] morning broadcast scheduled successfully');

    final pendingNotifications = await _notifications
        .pendingNotificationRequests();
    debugPrint(
      '[ScheduledBroadcast] Pending notifications: ${pendingNotifications.length}',
    );
    for (final notification in pendingNotifications) {
      debugPrint(
        '[ScheduledBroadcast] Pending: id=${notification.id}, title=${notification.title}',
      );
    }

    debugPrint(
      '[ScheduledBroadcast] Morning broadcast scheduled for ${settings.morningTime.formattedTime}',
    );
  }

  /// 调度晚上播报
  ///
  /// [settings] 定时播报设置
  Future<void> _scheduleEveningBroadcast(
    ScheduledBroadcastSettings settings,
  ) async {
    if (kIsWeb) {
      return;
    }

    // 提前获取天气数据
    String body = '点击查看明日天气详情';
    try {
      final weatherData = await _fetchDefaultCityWeather();
      body = _buildEveningContent(weatherData, settings);
      if (body.isEmpty) body = '晚间预报：${weatherData.current.text}';

      final isFromNetwork = await _isDataFresh(weatherData);
      if (!isFromNetwork) body += ' (来自本地缓存)';
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Evening pre-fetch failed: $e');
    }

    final scheduledDate = _nextInstanceOfTime(
      settings.eveningTime.hour,
      settings.eveningTime.minute,
    );

    if (scheduledDate == null) return;

    final scheduledAsLiveUpdate = await _tryScheduleLiveUpdateAt(
      scene: 'scheduled_evening_plan',
      id: _eveningNotificationId,
      triggerAt: DateTime.fromMillisecondsSinceEpoch(
        scheduledDate.millisecondsSinceEpoch,
      ),
      title: '晚间天气',
      body: body,
    );
    if (scheduledAsLiveUpdate) {
      debugPrint(
        '[ScheduledBroadcast] Evening live update scheduled successfully',
      );
      return;
    }

    debugPrint(
      '[ScheduledBroadcast] Scheduling evening broadcast for: $scheduledDate',
    );

    await _notifications.zonedSchedule(
      _eveningNotificationId,
      '晚间天气',
      body,
      scheduledDate,
      await _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening_broadcast',
    );

    debugPrint(
      '[ScheduledBroadcast] Evening broadcast scheduled for ${settings.eveningTime.formattedTime}',
    );
  }

  /// 检查数据是否为刚刚获取（非遗留缓存）
  Future<bool> _isDataFresh(WeatherData data) async {
    return DateTime.now().difference(data.lastUpdated).inMinutes < 5;
  }

  /// 检查电池优化（Android）
  Future<void> _checkBatteryOptimization() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      debugPrint('[ScheduledBroadcast] Battery optimization status: $status');
      if (status.isDenied) {
        debugPrint(
          '[ScheduledBroadcast] App is battery restricted, notifications may be delayed.',
        );
      }
    }
  }

  /// 计算下一个指定时间的实例
  ///
  /// [hour] 小时
  /// [minute] 分钟
  ///
  /// 返回下一个指定时间的TZDateTime实例
  tz.TZDateTime? _nextInstanceOfTime(int hour, int minute) {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Error calculating next instance: $e');
      return null;
    }
  }

  /// 构建通知详情
  ///
  /// 返回通知详情实例
  Future<NotificationDetails> _buildNotificationDetails() async {
    if (kIsWeb) {
      return const NotificationDetails();
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
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// 取消所有已调度的播报
  Future<void> cancelAllScheduledBroadcasts() async {
    if (kIsWeb) {
      return;
    }
    await _notifications.cancel(_morningNotificationId);
    await _notifications.cancel(_eveningNotificationId);
    await notificationServiceProvider.cancelScheduledAndroidLiveWeatherUpdate(
      _morningNotificationId,
    );
    await notificationServiceProvider.cancelScheduledAndroidLiveWeatherUpdate(
      _eveningNotificationId,
    );
    _lastCheckHour = -1; // 重置检查标记
  }

  /// 启动前台检查定时器
  void _startPulseTimer() {
    // 每分钟检查一次当前时间是否匹配播报时间
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndTriggerBroadcasts();
    });
  }

  /// 检查并触发播报（前台/桌面端补偿）
  Future<void> _checkAndTriggerBroadcasts() async {
    final settings = _currentSettings;
    if (settings == null || !settings.enabled) return;

    final now = DateTime.now();
    // 避免在同一个小时内重复推送
    if (now.hour == _lastCheckHour) return;

    // 检查早上播报
    if (settings.morningTime.enabled &&
        now.hour == settings.morningTime.hour &&
        now.minute >= settings.morningTime.minute) {
      debugPrint(
        '[ScheduledBroadcast] Pulse match: triggering morning broadcast',
      );
      _lastCheckHour = now.hour;
      await sendMorningBroadcast(settings);
    }

    // 检查晚上播报
    if (settings.eveningTime.enabled &&
        now.hour == settings.eveningTime.hour &&
        now.minute >= settings.eveningTime.minute) {
      debugPrint(
        '[ScheduledBroadcast] Pulse match: triggering evening broadcast',
      );
      _lastCheckHour = now.hour;
      await sendEveningBroadcast(settings);
    }
  }

  /// 发送早上播报
  ///
  /// [settings] 定时播报设置
  Future<void> sendMorningBroadcast(ScheduledBroadcastSettings settings) async {
    try {
      debugPrint('[ScheduledBroadcast] Starting morning broadcast...');
      final weatherData = await _fetchDefaultCityWeather();

      final title = '早上好 ☀️ ${weatherData.location.name}';
      String body = _buildMorningContent(weatherData, settings);

      // 如果数据较旧，增加缓存标记
      if (weatherData.lastUpdated.difference(DateTime.now()).abs().inHours >
          1) {
        body += '\n(来自本地缓存)';
      }
      debugPrint('[ScheduledBroadcast] Morning broadcast content: $body');

      final sentByLiveUpdate = await _trySendAsLiveUpdate(
        scene: 'scheduled_morning',
        title: title,
        body: body,
      );
      if (!sentByLiveUpdate) {
        await notificationServiceProvider.showWeatherAlert(
          id: _morningNotificationId,
          title: title,
          body: body,
          payload: 'morning_broadcast',
        );
      }
      debugPrint('[ScheduledBroadcast] Morning broadcast sent successfully');
    } catch (e, stackTrace) {
      debugPrint('[ScheduledBroadcast] Error sending morning broadcast: $e');
      debugPrint('[ScheduledBroadcast] StackTrace: $stackTrace');
      await _sendErrorNotification(
        '早安天气',
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// 发送晚上播报
  ///
  /// [settings] 定时播报设置
  Future<void> sendEveningBroadcast(ScheduledBroadcastSettings settings) async {
    try {
      debugPrint('[ScheduledBroadcast] Starting evening broadcast...');
      final weatherData = await _fetchDefaultCityWeather();

      final title = '晚上好 🌙 ${weatherData.location.name}';
      String body = _buildEveningContent(weatherData, settings);

      // 如果数据较旧，增加缓存标记
      if (weatherData.lastUpdated.difference(DateTime.now()).abs().inHours >
          1) {
        body += '\n(来自本地缓存)';
      }
      debugPrint('[ScheduledBroadcast] Evening broadcast content: $body');

      final sentByLiveUpdate = await _trySendAsLiveUpdate(
        scene: 'scheduled_evening',
        title: title,
        body: body,
      );
      if (!sentByLiveUpdate) {
        await notificationServiceProvider.showWeatherAlert(
          id: _eveningNotificationId,
          title: title,
          body: body,
          payload: 'evening_broadcast',
        );
      }
      debugPrint('[ScheduledBroadcast] Evening broadcast sent successfully');
    } catch (e, stackTrace) {
      debugPrint('[ScheduledBroadcast] Error sending evening broadcast: $e');
      debugPrint('[ScheduledBroadcast] StackTrace: $stackTrace');
      await _sendErrorNotification(
        '晚间天气',
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// 获取默认城市的天气数据
  ///
  /// 返回天气数据实例
  Future<WeatherData> _fetchDefaultCityWeather() async {
    debugPrint('[ScheduledBroadcast] Fetching default city weather...');

    final prefs = await SharedPreferences.getInstance();
    final cityStore = await CityRepository().loadStore();
    final cities = cityStore.cities;

    if (cities.isEmpty) {
      throw Exception('未找到保存的城市，请先打开应用获取位置');
    }

    final defaultCity = cityStore.defaultCityId == null
        ? cities.first
        : cities.firstWhere(
            (city) => city.id == cityStore.defaultCityId,
            orElse: () => cities.first,
          );

    debugPrint(
      '[ScheduledBroadcast] Default city: ${defaultCity.name} (ID: ${defaultCity.id})',
    );

    try {
      // 尝试获取最新的天气数据（带重试机制）
      final weatherData = await _fetchWithRetry(
        () => _weatherService.getFullWeatherData(defaultCity.id, defaultCity),
      );
      debugPrint('[ScheduledBroadcast] Weather data retrieved successfully');
      return weatherData;
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Network fetch failed, trying cache: $e');
      // 网络失败，尝试从本地缓存读取
      try {
        final key = 'weather_cache_${defaultCity.id}';
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          final data = WeatherData.fromJson(jsonDecode(jsonString));
          debugPrint(
            '[ScheduledBroadcast] Fallback to cache for ${defaultCity.name}',
          );
          return data;
        }
      } catch (cacheError) {
        debugPrint('[ScheduledBroadcast] Cache read failed: $cacheError');
      }

      throw Exception('天气数据获取失败: $e');
    }
  }

  Future<bool> _trySendAsLiveUpdate({
    required String scene,
    required String title,
    required String body,
  }) async {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NON_ANDROID_PLATFORM',
        message: '定时播报实时更新仅支持 Android',
        isAndroid: false,
        titlePreview: title,
      );
      return false;
    }

    final isSupported = await notificationServiceProvider
        .isAndroidLiveUpdateSupported();
    if (!isSupported) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'ANDROID_VERSION_UNSUPPORTED',
        message: '当前系统不支持实时更新通知（需 Android 16+）',
        isAndroid: true,
        isSupported: false,
        titlePreview: title,
      );
      return false;
    }

    final hasPermission = await notificationServiceProvider
        .checkNotificationPermission();
    if (!hasPermission) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NOTIFICATION_PERMISSION_DENIED',
        message: '未授予通知权限',
        isAndroid: true,
        isSupported: true,
        notificationPermission: false,
        titlePreview: title,
      );
      return false;
    }

    final canPromoted = await notificationServiceProvider
        .canPostPromotedNotifications();
    if (!canPromoted) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'PROMOTED_PERMISSION_DENIED',
        message: '系统未允许应用发布 Promoted 实时更新通知',
        isAndroid: true,
        isSupported: true,
        notificationPermission: true,
        promotedPermission: false,
        titlePreview: title,
      );
      return false;
    }

    final result = await notificationServiceProvider
        .showAndroidLiveWeatherUpdateDetailed(title: title, content: body);
    liveUpdateDiagnosticsService.record(
      scene: scene,
      success: result.success,
      code: result.code,
      message: result.message,
      isAndroid: true,
      isSupported: true,
      notificationPermission: true,
      promotedPermission: true,
      promotableCharacteristics: result.code == 'NOT_PROMOTABLE_CHARACTERISTICS'
          ? false
          : (result.success ? true : null),
      titlePreview: title,
    );
    return result.success;
  }

  Future<bool> _tryScheduleLiveUpdateAt({
    required String scene,
    required int id,
    required DateTime triggerAt,
    required String title,
    required String body,
  }) async {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NON_ANDROID_PLATFORM',
        message: '定时调度实时更新仅支持 Android',
        isAndroid: false,
        titlePreview: title,
      );
      return false;
    }

    final isSupported = await notificationServiceProvider
        .isAndroidLiveUpdateSupported();
    if (!isSupported) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'ANDROID_VERSION_UNSUPPORTED',
        message: '当前系统不支持实时更新通知（需 Android 16+）',
        isAndroid: true,
        isSupported: false,
        titlePreview: title,
      );
      return false;
    }

    final hasPermission = await notificationServiceProvider
        .checkNotificationPermission();
    if (!hasPermission) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'NOTIFICATION_PERMISSION_DENIED',
        message: '未授予通知权限',
        isAndroid: true,
        isSupported: true,
        notificationPermission: false,
        titlePreview: title,
      );
      return false;
    }

    final canPromoted = await notificationServiceProvider
        .canPostPromotedNotifications();
    if (!canPromoted) {
      liveUpdateDiagnosticsService.record(
        scene: scene,
        success: false,
        code: 'PROMOTED_PERMISSION_DENIED',
        message: '系统未允许应用发布 Promoted 实时更新通知',
        isAndroid: true,
        isSupported: true,
        notificationPermission: true,
        promotedPermission: false,
        titlePreview: title,
      );
      return false;
    }

    final result = await notificationServiceProvider
        .scheduleAndroidLiveWeatherUpdate(
          id: id,
          triggerAt: triggerAt,
          title: title,
          content: body,
        );
    liveUpdateDiagnosticsService.record(
      scene: scene,
      success: result.success,
      code: result.code,
      message: result.message,
      isAndroid: true,
      isSupported: true,
      notificationPermission: true,
      promotedPermission: true,
      titlePreview: title,
    );
    return result.success;
  }

  /// 带重试机制的请求封装
  Future<T> _fetchWithRetry<T>(
    Future<T> Function() task, {
    int retries = 3,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await task();
      } catch (e) {
        if (attempts >= retries) rethrow;
        final isNetworkError =
            e is DioException &&
            (e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout);

        if (!isNetworkError) rethrow; // 只有网络错误才重试

        debugPrint(
          '[ScheduledBroadcast] Retry attempt $attempts after error: $e',
        );
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  /// 构建早上播报内容
  ///
  /// [data] 天气数据
  /// [settings] 定时播报设置
  ///
  /// 返回播报内容字符串
  String _buildMorningContent(
    WeatherData data,
    ScheduledBroadcastSettings settings,
  ) {
    final buffer = StringBuffer();
    final current = data.current;
    final today = data.daily.isNotEmpty ? data.daily.first : null;

    buffer.writeln('今日天气：${current.text}');
    buffer.write('当前温度：${current.temp}°C');

    if (today != null) {
      buffer.write(' | ${today.tempMin}°C ~ ${today.tempMax}°C');
    }

    if (settings.includeWindInfo) {
      buffer.writeln();
      buffer.write('风向风力：${current.windDir} ${current.windScale}级');
    }

    if (settings.includeAirQuality) {
      buffer.writeln();
      buffer.write('湿度：${current.humidity}%');
    }

    return buffer.toString().trim();
  }

  /// 构建晚上播报内容
  ///
  /// [data] 天气数据
  /// [settings] 定时播报设置
  ///
  /// 返回播报内容字符串
  String _buildEveningContent(
    WeatherData data,
    ScheduledBroadcastSettings settings,
  ) {
    final buffer = StringBuffer();
    final tomorrow = data.daily.length > 1 ? data.daily[1] : null;

    if (tomorrow != null) {
      buffer.writeln('明日天气：${tomorrow.textDay}');
      buffer.write('温度：${tomorrow.tempMin}°C ~ ${tomorrow.tempMax}°C');

      if (settings.includeWindInfo) {
        buffer.writeln();
        buffer.write('风向风力：${tomorrow.windDirDay} ${tomorrow.windScaleDay}级');
      }

      if (tomorrow.precip.isNotEmpty &&
          double.tryParse(tomorrow.precip) != null) {
        final precip = double.parse(tomorrow.precip);
        if (precip > 0) {
          buffer.writeln();
          buffer.write('降水量：${tomorrow.precip}mm');
        }
      }
    } else {
      buffer.write('暂无明日天气数据');
    }

    return buffer.toString().trim();
  }

  /// 发送错误通知
  ///
  /// [title] 通知标题
  /// [message] 错误消息
  Future<void> _sendErrorNotification(String title, String message) async {
    await notificationServiceProvider.showWeatherAlert(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
    );
  }
}

/// 定时播报服务的Provider
final scheduledBroadcastServiceProvider = ScheduledBroadcastService();
