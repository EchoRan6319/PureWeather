import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_localizations.dart';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// 7天天气预报组件
///
/// 显示未来7天的天气预报，包括日期、天气图标、天气状态和温度范围
class DailyForecast extends StatelessWidget {
  /// 每日天气预报数据
  final List<DailyWeather> daily;

  /// 当前天气数据
  final CurrentWeather? currentWeather;

  /// 日出时间
  final String? sunrise;

  /// 日落时间
  final String? sunset;

  /// 温度单位
  final String temperatureUnit;

  /// 构造函数
  ///
  /// [daily]: 每日天气预报数据
  /// [currentWeather]: 当前天气数据
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
  /// [temperatureUnit]: 温度单位，默认摄氏度
  const DailyForecast({
    super.key,
    required this.daily,
    this.currentWeather,
    this.sunrise,
    this.sunset,
    this.temperatureUnit = 'celsius',
  });

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();
    final tokens = context.uiTokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('7天预报'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 每日预报列表
            ...daily.take(7).toList().asMap().entries.map((entry) {
              return _DailyItem(
                weather: entry.value,
                isToday: entry.key == 0,
                currentWeather: entry.key == 0 ? currentWeather : null,
                sunrise: entry.key == 0 ? sunrise : null,
                sunset: entry.key == 0 ? sunset : null,
                temperatureUnit: temperatureUnit,
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * entry.key));
            }),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

/// 每日天气预报项组件
///
/// 显示单个日期的天气信息
class _DailyItem extends StatelessWidget {
  /// 每日天气数据
  final DailyWeather weather;

  /// 是否为今天
  final bool isToday;

  /// 当前天气数据
  final CurrentWeather? currentWeather;

  /// 日出时间
  final String? sunrise;

  /// 日落时间
  final String? sunset;

  /// 温度单位
  final String temperatureUnit;

  /// 构造函数
  ///
  /// [weather]: 每日天气数据
  /// [isToday]: 是否为今天
  /// [currentWeather]: 当前天气数据
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
  /// [temperatureUnit]: 温度单位
  const _DailyItem({
    required this.weather,
    this.isToday = false,
    this.currentWeather,
    this.sunrise,
    this.sunset,
    this.temperatureUnit = 'celsius',
  });

  /// 判断是否为夜间
  bool _isNightTime() {
    final now = DateTime.now();

    if (sunrise == null ||
        sunset == null ||
        sunrise!.isEmpty ||
        sunset!.isEmpty) {
      return now.hour >= 18 || now.hour < 6;
    }

    final sunriseParts = sunrise!.split(':');
    final sunsetParts = sunset!.split(':');

    if (sunriseParts.length < 2 || sunsetParts.length < 2) {
      return now.hour >= 18 || now.hour < 6;
    }

    final sunriseHour = int.tryParse(sunriseParts[0]) ?? 6;
    final sunriseMinute = int.tryParse(sunriseParts[1]) ?? 0;
    final sunsetHour = int.tryParse(sunsetParts[0]) ?? 18;
    final sunsetMinute = int.tryParse(sunsetParts[1]) ?? 0;

    final sunriseMinutes = sunriseHour * 60 + sunriseMinute;
    final sunsetMinutes = sunsetHour * 60 + sunsetMinute;
    final currentMinutes = now.hour * 60 + now.minute;

    return currentMinutes < sunriseMinutes || currentMinutes >= sunsetMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(weather.fxDate);
    final weekday = date != null ? _getWeekday(context, date.weekday) : '--';
    final dateStr = date != null ? DateFormat('MM/dd').format(date) : '--/--';

    int icon;
    String text;

    // 今天显示当前天气，其他天显示白天天气
    if (isToday && currentWeather != null) {
      icon = int.tryParse(currentWeather!.icon) ?? 100;
      text = currentWeather!.text;
    } else {
      icon =
          int.tryParse(weather.iconDay) ??
          int.tryParse(weather.iconNight) ??
          100;
      text = weather.textDay.isNotEmpty ? weather.textDay : weather.textNight;
    }

    final isNight = isToday ? _isNightTime() : false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // 日期和星期
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isToday ? context.tr('今天') : weekday,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // 天气图标和状态
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  WeatherCode.getWeatherIcon(icon, isNight: isNight),
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.tr(text),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 温度范围
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${WeatherCode.convertTemperature(weather.tempMin, toFahrenheit: temperatureUnit == 'fahrenheit')}${temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${WeatherCode.convertTemperature(weather.tempMax, toFahrenheit: temperatureUnit == 'fahrenheit')}${temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取星期几
  ///
  /// [weekday]: 星期几的数字表示（1-7）
  String _getWeekday(BuildContext context, int weekday) {
    if (Localizations.localeOf(context).languageCode == 'en') {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[weekday - 1];
    }

    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${weekdays[weekday - 1]}';
  }
}
