import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'qweather_service.dart';
import 'notification_service.dart';
import '../providers/scheduled_broadcast_provider.dart';
import '../models/weather_models.dart';

class ScheduledBroadcastService {
  static final ScheduledBroadcastService _instance =
      ScheduledBroadcastService._internal();
  factory ScheduledBroadcastService() => _instance;
  ScheduledBroadcastService._internal();

  final QWeatherService _weatherService = QWeatherService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _morningNotificationId = 10001;
  static const int _eveningNotificationId = 10002;
  static const String _channelId = 'scheduled_broadcast';
  static const String _channelName = '定时播报';
  static const String _channelDescription = '定时推送天气信息';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

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

  Future<void> scheduleBroadcasts(ScheduledBroadcastSettings settings) async {
    await initialize();
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

  Future<void> _scheduleMorningBroadcast(
    ScheduledBroadcastSettings settings,
  ) async {
    final scheduledDate = _nextInstanceOfTime(
      settings.morningTime.hour,
      settings.morningTime.minute,
    );

    debugPrint(
      '[ScheduledBroadcast] Scheduling morning broadcast for: $scheduledDate',
    );

    await _notifications.zonedSchedule(
      _morningNotificationId,
      '早安天气',
      '点击查看今日天气详情',
      scheduledDate,
      await _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning_broadcast',
    );

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

  Future<void> _scheduleEveningBroadcast(
    ScheduledBroadcastSettings settings,
  ) async {
    final scheduledDate = _nextInstanceOfTime(
      settings.eveningTime.hour,
      settings.eveningTime.minute,
    );

    debugPrint(
      '[ScheduledBroadcast] Scheduling evening broadcast for: $scheduledDate',
    );

    await _notifications.zonedSchedule(
      _eveningNotificationId,
      '晚间天气',
      '点击查看明日天气详情',
      scheduledDate,
      await _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening_broadcast',
    );

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
      '[ScheduledBroadcast] Evening broadcast scheduled for ${settings.eveningTime.formattedTime}',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
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
  }

  Future<NotificationDetails> _buildNotificationDetails() async {
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

  Future<void> cancelAllScheduledBroadcasts() async {
    await _notifications.cancel(_morningNotificationId);
    await _notifications.cancel(_eveningNotificationId);
  }

  Future<void> sendMorningBroadcast(ScheduledBroadcastSettings settings) async {
    try {
      debugPrint('[ScheduledBroadcast] Starting morning broadcast...');
      final weatherData = await _fetchDefaultCityWeather();

      final title = '早上好 ☀️ ${weatherData.location.name}';
      final body = _buildMorningContent(weatherData, settings);
      debugPrint('[ScheduledBroadcast] Morning broadcast content: $body');

      await notificationServiceProvider.showWeatherAlert(
        id: _morningNotificationId,
        title: title,
        body: body,
        payload: 'morning_broadcast',
      );
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

  Future<void> sendEveningBroadcast(ScheduledBroadcastSettings settings) async {
    try {
      debugPrint('[ScheduledBroadcast] Starting evening broadcast...');
      final weatherData = await _fetchDefaultCityWeather();

      final title = '晚上好 🌙 ${weatherData.location.name}';
      final body = _buildEveningContent(weatherData, settings);
      debugPrint('[ScheduledBroadcast] Evening broadcast content: $body');

      await notificationServiceProvider.showWeatherAlert(
        id: _eveningNotificationId,
        title: title,
        body: body,
        payload: 'evening_broadcast',
      );
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

  Future<WeatherData> _fetchDefaultCityWeather() async {
    debugPrint('[ScheduledBroadcast] Fetching default city weather...');

    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getString('saved_cities');

    if (citiesJson == null) {
      throw Exception('未找到保存的城市，请先打开应用获取位置');
    }

    final List<dynamic> decoded = jsonDecode(citiesJson);
    final cities = decoded.map((e) => Location.fromJson(e)).toList();

    Location? defaultCity;
    try {
      defaultCity = cities.firstWhere((city) => city.isDefault);
    } catch (_) {
      defaultCity = cities.isNotEmpty ? cities.first : null;
    }

    if (defaultCity == null) {
      throw Exception('未找到默认城市，请先打开应用获取位置');
    }

    debugPrint(
      '[ScheduledBroadcast] Default city: ${defaultCity.name} (ID: ${defaultCity.id})',
    );

    try {
      final weatherData = await _weatherService.getFullWeatherData(
        defaultCity.id,
        defaultCity,
      );
      debugPrint('[ScheduledBroadcast] Weather data retrieved successfully');
      return weatherData;
    } catch (e) {
      debugPrint('[ScheduledBroadcast] Failed to get weather data: $e');
      throw Exception('天气数据获取失败: $e');
    }
  }

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

  Future<void> _sendErrorNotification(String title, String message) async {
    await notificationServiceProvider.showWeatherAlert(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
    );
  }
}

final scheduledBroadcastServiceProvider = ScheduledBroadcastService();
