import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';

class HourlyForecast extends StatelessWidget {
  final List<HourlyWeather> hourly;

  const HourlyForecast({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final filteredHourly = _filterHourlyData(hourly, now);

    if (filteredHourly.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildHourlyList(context, filteredHourly, now),
          ],
        ),
      ),
    );
  }

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

  Widget _buildHourlyList(
    BuildContext context,
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const targetVisibleItems = 5;
        const itemGap = 4.0;
        final itemWidth =
            (screenWidth - (itemGap * (targetVisibleItems - 1))) /
            targetVisibleItems;

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            cacheExtent: 1000,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < hourly.length - 1 ? itemGap : 0,
                ),
                child: SizedBox(
                  width: itemWidth,
                  child: _HourlyItem(weather: hourly[index], now: now),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<HourlyWeather> _filterHourlyData(
    List<HourlyWeather> hourly,
    DateTime now,
  ) {
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

      if ((compareTime.isAtSameMomentAs(nextHour) ||
              compareTime.isAfter(nextHour)) &&
          compareTime.isBefore(endHour)) {
        result.add(h);
      }
    }

    result.sort((a, b) {
      final timeA = DateTime.tryParse(a.fxTime) ?? DateTime(2000);
      final timeB = DateTime.tryParse(b.fxTime) ?? DateTime(2000);
      return timeA.compareTo(timeB);
    });

    return result;
  }
}

class _HourlyItem extends StatelessWidget {
  final HourlyWeather weather;
  final DateTime now;

  const _HourlyItem({required this.weather, required this.now});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.tryParse(weather.fxTime);
    final localTime = time?.toLocal();
    final hour = localTime?.hour ?? 0;
    final isNight = hour >= 22 || hour < 6;
    final iconCode = int.tryParse(weather.icon) ?? 100;
    final hasPrecipitation = weather.pop != '0' && weather.pop.isNotEmpty;

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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
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
    return Text(
      '${weather.temp}°',
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
    );
  }
}
