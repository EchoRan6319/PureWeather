import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';

/// 24小时天气预报组件
/// 
/// 显示未来24小时的天气预报，包括时间、天气图标、温度和降水概率
class HourlyForecast extends StatelessWidget {
  /// 小时天气预报数据
  final List<HourlyWeather> hourly;
  /// 日出时间
  final String? sunrise;
  /// 日落时间
  final String? sunset;
  /// 温度单位
  final String temperatureUnit;

  /// 构造函数
  /// 
  /// [hourly]: 小时天气预报数据
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
  /// [temperatureUnit]: 温度单位，默认摄氏度
  const HourlyForecast({
    super.key,
    required this.hourly,
    this.sunrise,
    this.sunset,
    this.temperatureUnit = 'celsius',
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    // 过滤出未来24小时的数据
    final filteredHourly = _filterHourlyData(hourly, now);

    if (filteredHourly.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            _buildHourlyList(context, filteredHourly, now),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  /// 
  /// [context]: 上下文
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '24小时预报',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// 构建小时预报列表
  /// 
  /// [context]: 上下文
  /// [hourly]: 小时天气预报数据
  /// [now]: 当前时间
  Widget _buildHourlyList(
    BuildContext context,
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
    // 检查是否有降水数据
    final hasAnyPrecipitation = hourly.any(
      (h) => h.pop != '0' && h.pop.isNotEmpty,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const targetVisibleItems = 5;
        const itemGap = 4.0;
        // 计算每个小时项的宽度
        final itemWidth =
            (screenWidth - (itemGap * (targetVisibleItems - 1))) /
            targetVisibleItems;

        return SizedBox(
          // 根据是否有降水数据调整高度
          height: hasAnyPrecipitation ? 120 : 100,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              cacheExtent: 1000,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < hourly.length - 1 ? itemGap : 0,
                  ),
                  child: SizedBox(
                    width: itemWidth,
                    child: _HourlyItem(
                      weather: hourly[index],
                      now: now,
                      sunrise: sunrise,
                      sunset: sunset,
                      showPrecipitation: hasAnyPrecipitation,
                      temperatureUnit: temperatureUnit,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 过滤小时天气预报数据
  /// 
  /// [hourly]: 原始小时天气预报数据
  /// [now]: 当前时间
  /// 
  /// 返回未来24小时的天气预报数据
  List<HourlyWeather> _filterHourlyData(
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
    // 计算开始时间（下一小时）和结束时间（24小时后）
    final nextHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 1));
    final endHour = nextHour.add(const Duration(hours: 24));

    final result = <HourlyWeather>[];

    for (final h in hourly) {
      final hourTime = DateTime.tryParse(h.fxTime);
      if (hourTime == null) continue;

      final localHourTime = hourTime.toLocal();
      final compareTime = DateTime(
        localHourTime.year,
        localHourTime.month,
        localHourTime.day,
        localHourTime.hour,
      );

      // 筛选出在开始时间和结束时间之间的数据
      if ((compareTime.isAtSameMomentAs(nextHour) ||
              compareTime.isAfter(nextHour)) &&
          compareTime.isBefore(endHour)) {
        result.add(h);
      }
    }

    // 按时间排序
    result.sort((a, b) {
      final timeA = DateTime.tryParse(a.fxTime) ?? DateTime(2000);
      final timeB = DateTime.tryParse(b.fxTime) ?? DateTime(2000);
      return timeA.compareTo(timeB);
    });

    return result;
  }
}

/// 小时天气预报项组件
/// 
/// 显示单个小时的天气信息
class _HourlyItem extends StatelessWidget {
  /// 小时天气数据
  final HourlyWeather weather;
  /// 当前时间
  final DateTime now;
  /// 日出时间
  final String? sunrise;
  /// 日落时间
  final String? sunset;
  /// 是否显示降水概率
  final bool showPrecipitation;
  /// 温度单位
  final String temperatureUnit;

  /// 构造函数
  /// 
  /// [weather]: 小时天气数据
  /// [now]: 当前时间
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
  /// [showPrecipitation]: 是否显示降水概率
  /// [temperatureUnit]: 温度单位
  const _HourlyItem({
    required this.weather,
    required this.now,
    this.sunrise,
    this.sunset,
    this.showPrecipitation = true,
    this.temperatureUnit = 'celsius',
  });

  /// 判断是否为夜间
  /// 
  /// [time]: 时间
  bool _isNightTime(DateTime time) {
    if (sunrise != null &&
        sunset != null &&
        sunrise!.isNotEmpty &&
        sunset!.isNotEmpty) {
      final sunriseParts = sunrise!.split(':');
      final sunsetParts = sunset!.split(':');

      if (sunriseParts.length >= 2 && sunsetParts.length >= 2) {
        final sunriseHour = int.tryParse(sunriseParts[0]) ?? 6;
        final sunriseMinute = int.tryParse(sunriseParts[1]) ?? 0;
        final sunsetHour = int.tryParse(sunsetParts[0]) ?? 18;
        final sunsetMinute = int.tryParse(sunsetParts[1]) ?? 0;

        final sunriseMinutes = sunriseHour * 60 + sunriseMinute;
        final sunsetMinutes = sunsetHour * 60 + sunsetMinute;
        final currentMinutes = time.hour * 60 + time.minute;

        return currentMinutes < sunriseMinutes ||
            currentMinutes >= sunsetMinutes;
      }
    }

    // 默认规则：18点后或6点前为夜间
    return time.hour >= 18 || time.hour < 6;
  }

  @override
  Widget build(BuildContext context) {
    final time = DateTime.tryParse(weather.fxTime);
    final localTime = time?.toLocal();
    final isNight = localTime != null ? _isNightTime(localTime) : false;
    final iconCode = int.tryParse(weather.icon) ?? 100;
    final hasPrecipitation =
        showPrecipitation && weather.pop != '0' && weather.pop.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeText(context, localTime),
        _buildWeatherIcon(context, iconCode, isNight),
        _buildTempText(context),
        if (hasPrecipitation) _buildPrecipitation(context),
      ],
    );
  }

  /// 构建时间文本
  /// 
  /// [context]: 上下文
  /// [time]: 时间
  Widget _buildTimeText(BuildContext context, DateTime? time) {
    final colorScheme = Theme.of(context).colorScheme;

    if (time == null) {
      return Text(
        '--:--',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }

    final timeText = '${time.hour}:00';

    return Text(
      timeText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 构建天气图标
  /// 
  /// [context]: 上下文
  /// [iconCode]: 图标代码
  /// [isNight]: 是否为夜间
  Widget _buildWeatherIcon(BuildContext context, int iconCode, bool isNight) {
    return Icon(
      WeatherCode.getWeatherIcon(iconCode, isNight: isNight),
      size: 26,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// 构建温度文本
  /// 
  /// [context]: 上下文
  Widget _buildTempText(BuildContext context) {
    final convertedTemp = WeatherCode.convertTemperature(
      weather.temp,
      toFahrenheit: temperatureUnit == 'fahrenheit',
    );
    final unit = temperatureUnit == 'fahrenheit' ? '°F' : '°';
    return Text(
      '$convertedTemp$unit',
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// 构建降水概率
  /// 
  /// [context]: 上下文
  Widget _buildPrecipitation(BuildContext context) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop,
              size: 10,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 1),
            Text(
              '${weather.pop}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 9,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }
}
