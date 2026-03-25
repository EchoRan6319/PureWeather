import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_localizations.dart';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

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
  /// 次日日出时间
  final String? nextSunrise;
  /// 温度单位
  final String temperatureUnit;

  /// 构造函数
  /// 
  /// [hourly]: 小时天气预报数据
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
  /// [nextSunrise]: 次日日出时间
  /// [temperatureUnit]: 温度单位，默认摄氏度
  const HourlyForecast({
    super.key,
    required this.hourly,
    this.sunrise,
    this.sunset,
    this.nextSunrise,
    this.temperatureUnit = 'celsius',
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return _buildEmptyState(context);
    }

    return StreamBuilder<int>(
      stream: Stream<int>.periodic(const Duration(minutes: 1), (count) => count),
      initialData: 0,
      builder: (context, _) {
        final now = DateTime.now();
        // 过滤出未来24小时的数据
        final filteredHourly = _filterHourlyData(hourly, now);

        if (kDebugMode) {
          debugPrint('[HourlyCard] input=${hourly.length} filtered=${filteredHourly.length} now=$now');
        }

        if (filteredHourly.isEmpty) {
          return _buildEmptyState(context, subtitle: context.tr('小时数据已过期或时间解析失败'));
        }

        return Container(
          decoration: BoxDecoration(
            color: context.uiTokens.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.uiTokens.cardBorder),
          ),
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
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {String? subtitle}) {
    final displaySubtitle = subtitle ?? context.tr('暂无小时预报数据');
    return Container(
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displaySubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
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
          context.tr('24小时预报'),
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
                      nextSunrise: nextSunrise,
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
    final parsed = <MapEntry<HourlyWeather, DateTime>>[];
    var invalidTimeCount = 0;

    for (final h in hourly) {
      final hourTime = _parseFxTime(h.fxTime);
      if (hourTime == null) {
        invalidTimeCount++;
        continue;
      }
      parsed.add(MapEntry(h, hourTime));
    }

    // 按时间排序后优先取“当前时刻之后”的24条
    parsed.sort((a, b) => a.value.compareTo(b.value));
    final windowEnd = now.add(const Duration(hours: 24));
    final upcoming = parsed
        .where(
          (entry) =>
              !entry.value.isBefore(now) &&
              !entry.value.isAfter(windowEnd),
        )
        .map((entry) => entry.key)
        .toList();
    if (upcoming.isNotEmpty) {
      if (kDebugMode) {
        final firstTime = _parseFxTime(upcoming.first.fxTime);
        final lastTime = _parseFxTime(upcoming.last.fxTime);
        debugPrint(
          '[HourlyFilter] mode=window invalidFxTime=$invalidTimeCount kept=${upcoming.length} first=$firstTime last=$lastTime now=$now end=$windowEnd',
        );
      }
      return upcoming;
    }

    // 回退：若数据按整点返回，允许从当前小时整点开始显示
    final alignedWindowStart = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );
    final fallback = parsed
        .where(
          (entry) =>
              !entry.value.isBefore(alignedWindowStart) &&
              !entry.value.isAfter(windowEnd),
        )
        .map((entry) => entry.key)
        .toList();
    if (fallback.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[HourlyFilter] mode=alignedWindow invalidFxTime=$invalidTimeCount kept=${fallback.length} now=$now start=$alignedWindowStart end=$windowEnd',
        );
      }
      return fallback;
    }

    if (kDebugMode) {
      debugPrint(
        '[HourlyFilter] mode=empty invalidFxTime=$invalidTimeCount parsed=${parsed.length} now=$now end=$windowEnd',
      );
    }

    return const <HourlyWeather>[];
  }

  static DateTime? _parseFxTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    var parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();

    final normalized = value.replaceFirst(' ', 'T');
    parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed.toLocal();

    final tzNoColon = RegExp(r'([+-]\d{2})(\d{2})$');
    if (tzNoColon.hasMatch(normalized)) {
      final withColon = normalized.replaceFirstMapped(
        tzNoColon,
        (m) => '${m.group(1)}:${m.group(2)}',
      );
      parsed = DateTime.tryParse(withColon);
      if (parsed != null) return parsed.toLocal();
    }

    return null;
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
  /// 次日日出时间
  final String? nextSunrise;
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
  /// [nextSunrise]: 次日日出时间
  /// [showPrecipitation]: 是否显示降水概率
  /// [temperatureUnit]: 温度单位
  const _HourlyItem({
    required this.weather,
    required this.now,
    this.sunrise,
    this.sunset,
    this.nextSunrise,
    this.showPrecipitation = true,
    this.temperatureUnit = 'celsius',
  });

  /// 判断是否为夜间
  /// 
  /// [time]: 时间
  bool _isNightTime(DateTime time) {
    final sunriseMinutes = _parseMinutes(sunrise);
    final sunsetMinutes = _parseMinutes(sunset);
    final nextSunriseMinutes = _parseMinutes(nextSunrise);
    final currentMinutes = time.hour * 60 + time.minute;

    if (sunriseMinutes != null && sunsetMinutes != null) {
      final forecastDate = DateTime(time.year, time.month, time.day);
      final todayDate = DateTime(now.year, now.month, now.day);

      // 今天：日出前或日落后为夜间
      if (!forecastDate.isAfter(todayDate)) {
        return currentMinutes < sunriseMinutes ||
            currentMinutes >= sunsetMinutes;
      }

      // 明天（及未来）：优先使用次日日出，保证“日落后到次日日出”始终夜间
      final sunriseForFutureDay = nextSunriseMinutes ?? sunriseMinutes;
      if (currentMinutes < sunriseForFutureDay) {
        return true;
      }

      // 未来天的日落时间没有单独透传时，复用当日日落时刻判断
      return currentMinutes >= sunsetMinutes;
    }

    // 默认规则：18点后或6点前为夜间
    return time.hour >= 18 || time.hour < 6;
  }

  int? _parseMinutes(String? hhmm) {
    if (hhmm == null || hhmm.isEmpty) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  @override
  Widget build(BuildContext context) {
    final localTime = HourlyForecast._parseFxTime(weather.fxTime);
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
