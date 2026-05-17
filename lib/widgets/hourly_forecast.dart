import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
class HourlyForecast extends StatefulWidget {
  final List<HourlyWeather> hourly;
  final String? sunrise;
  final String? sunset;
  final String? nextSunrise;
  final String temperatureUnit;

  const HourlyForecast({
    super.key,
    required this.hourly,
    this.sunrise,
    this.sunset,
    this.nextSunrise,
    this.temperatureUnit = 'celsius',
  });

  @override
  State<HourlyForecast> createState() => _HourlyForecastState();

  static DateTime? parseFxTime(String raw) {
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

class _HourlyForecastState extends State<HourlyForecast> {
  late List<HourlyWeather> _filteredHourly;
  Timer? _hourRefreshTimer;

  @override
  void initState() {
    super.initState();
    _filteredHourly = _filterHourlyData(widget.hourly, DateTime.now());
    _scheduleNextHourRefresh();
  }

  @override
  void didUpdateWidget(HourlyForecast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hourly != widget.hourly) {
      _filteredHourly = _filterHourlyData(widget.hourly, DateTime.now());
    }
  }

  @override
  void dispose() {
    _hourRefreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleNextHourRefresh() {
    _hourRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(const Duration(hours: 1));
    _hourRefreshTimer = Timer(nextHour.difference(now), () {
      if (!mounted) return;
      setState(() {
        _filteredHourly = _filterHourlyData(widget.hourly, DateTime.now());
      });
      _scheduleNextHourRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hourly.isEmpty) {
      return _buildEmptyState(context);
    }

    final now = DateTime.now();

    if (_filteredHourly.isEmpty) {
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
            _buildHourlyList(context, _filteredHourly, now),
          ],
        ),
      ),
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
                  LucideIcons.info,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          LucideIcons.clock,
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

  Widget _buildHourlyList(
    BuildContext context,
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
    final hasAnyPrecipitation = hourly.any(
      (h) => h.pop != '0' && h.pop.isNotEmpty,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const targetVisibleItems = 5;
        const itemGap = 4.0;
        final itemWidth =
            (screenWidth - (itemGap * (targetVisibleItems - 1))) /
            targetVisibleItems;

        return SizedBox(
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
                      sunrise: widget.sunrise,
                      sunset: widget.sunset,
                      nextSunrise: widget.nextSunrise,
                      showPrecipitation: hasAnyPrecipitation,
                      temperatureUnit: widget.temperatureUnit,
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

  List<HourlyWeather> _filterHourlyData(
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
    final parsed = <MapEntry<HourlyWeather, DateTime>>[];
    var invalidTimeCount = 0;

    for (final h in hourly) {
      final hourTime = HourlyForecast.parseFxTime(h.fxTime);
      if (hourTime == null) {
        invalidTimeCount++;
        continue;
      }
      parsed.add(MapEntry(h, hourTime));
    }

    parsed.sort((a, b) => a.value.compareTo(b.value));
    final windowEnd = now.add(const Duration(hours: 24));
    final upcoming = parsed
        .where(
          (entry) =>
              !entry.value.isBefore(now) && !entry.value.isAfter(windowEnd),
        )
        .map((entry) => entry.key)
        .toList();
    if (upcoming.isNotEmpty) {
      return upcoming;
    }

    final alignedWindowStart = DateTime(now.year, now.month, now.day, now.hour);
    final fallback = parsed
        .where(
          (entry) =>
              !entry.value.isBefore(alignedWindowStart) &&
              !entry.value.isAfter(windowEnd),
        )
        .map((entry) => entry.key)
        .toList();
    if (fallback.isNotEmpty) {
      return fallback;
    }

    if (kDebugMode) {
      debugPrint(
        '[HourlyFilter] mode=empty invalidFxTime=$invalidTimeCount parsed=${parsed.length} now=$now end=$windowEnd',
      );
    }

    return const <HourlyWeather>[];
  }
}

/// 小时天气预报项组件
class _HourlyItem extends StatelessWidget {
  final HourlyWeather weather;
  final DateTime now;
  final String? sunrise;
  final String? sunset;
  final String? nextSunrise;
  final bool showPrecipitation;
  final String temperatureUnit;

  const _HourlyItem({
    required this.weather,
    required this.now,
    this.sunrise,
    this.sunset,
    this.nextSunrise,
    this.showPrecipitation = true,
    this.temperatureUnit = 'celsius',
  });

  @override
  Widget build(BuildContext context) {
    final localTime = HourlyForecast.parseFxTime(weather.fxTime);
    final isNight = localTime != null
        ? WeatherCode.isNightTime(
            localTime,
            sunrise: sunrise,
            sunset: sunset,
            nextSunrise: nextSunrise,
            referenceNow: now,
          )
        : false;
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
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWeatherIcon(BuildContext context, int iconCode, bool isNight) {
    return Icon(
      WeatherCode.getWeatherIcon(iconCode, isNight: isNight),
      size: 26,
      color: Theme.of(context).colorScheme.primary,
    );
  }

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

  Widget _buildPrecipitation(BuildContext context) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.droplet,
              size: 12,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 2),
            Text(
              '${weather.pop}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }
}
