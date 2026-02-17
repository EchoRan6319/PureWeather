import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';

class HourlyForecast extends StatelessWidget {
  final List<HourlyWeather> hourly;
  final String? sunrise;
  final String? sunset;
  final String temperatureUnit;

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
  final String? sunrise;
  final String? sunset;
  final bool showPrecipitation;
  final String temperatureUnit;

  const _HourlyItem({
    required this.weather,
    required this.now,
    this.sunrise,
    this.sunset,
    this.showPrecipitation = true,
    this.temperatureUnit = 'celsius',
  });

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
