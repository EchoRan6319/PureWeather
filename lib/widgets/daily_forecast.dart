import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_models.dart';
import '../core/constants/app_constants.dart';

class DailyForecast extends StatelessWidget {
  final List<DailyWeather> daily;
  final CurrentWeather? currentWeather;
  final String? sunrise;
  final String? sunset;
  final String temperatureUnit;

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '7天预报',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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

class _DailyItem extends StatelessWidget {
  final DailyWeather weather;
  final bool isToday;
  final CurrentWeather? currentWeather;
  final String? sunrise;
  final String? sunset;
  final String temperatureUnit;

  const _DailyItem({
    required this.weather,
    this.isToday = false,
    this.currentWeather,
    this.sunrise,
    this.sunset,
    this.temperatureUnit = 'celsius',
  });

  bool _isNightTime() {
    if (sunrise == null ||
        sunset == null ||
        sunrise!.isEmpty ||
        sunset!.isEmpty) {
      final now = DateTime.now();
      return now.hour >= 18 || now.hour < 6;
    }

    final sunriseParts = sunrise!.split(':');
    final sunsetParts = sunset!.split(':');

    if (sunriseParts.length < 2 || sunsetParts.length < 2) {
      return false;
    }

    final sunriseHour = int.tryParse(sunriseParts[0]) ?? 6;
    final sunriseMinute = int.tryParse(sunriseParts[1]) ?? 0;
    final sunsetHour = int.tryParse(sunsetParts[0]) ?? 18;
    final sunsetMinute = int.tryParse(sunsetParts[1]) ?? 0;

    final now = DateTime.now();
    final sunriseMinutes = sunriseHour * 60 + sunriseMinute;
    final sunsetMinutes = sunsetHour * 60 + sunsetMinute;
    final currentMinutes = now.hour * 60 + now.minute;

    return currentMinutes < sunriseMinutes || currentMinutes >= sunsetMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(weather.fxDate);
    final weekday = date != null ? _getWeekday(date.weekday) : '--';
    final dateStr = date != null ? DateFormat('MM/dd').format(date) : '--/--';

    int icon;
    String text;

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
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? '今天' : weekday,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
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
                    text,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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

  String _getWeekday(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${weekdays[weekday - 1]}';
  }
}
