import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weather_models.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../services/caiyun_service.dart';
import '../../widgets/hourly_forecast.dart';
import '../../widgets/daily_forecast.dart';
import '../../widgets/weather_alert_card.dart';
import '../../widgets/air_quality_card.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  Future<void> _loadWeather() async {
    final defaultCity = ref.read(defaultCityProvider);
    if (defaultCity != null) {
      await ref.read(weatherProvider.notifier).loadWeather(defaultCity);
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(weatherProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final defaultCity = ref.watch(defaultCityProvider);

    ref.listen(defaultCityProvider, (previous, next) {
      if (next != null) {
        ref.read(weatherProvider.notifier).loadWeather(next);
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildCurrentWeather(weatherState, defaultCity),
              ),
            ),
            SliverToBoxAdapter(child: _buildContent(weatherState)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherState state, Location? location) {
    if (state.isLoading && state.weatherData == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final weather = state.weatherData;
    if (weather == null) {
      return _buildEmptyState();
    }

    final isNight = _isNightTime(weather.current.obsTime);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNight
              ? [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.surface,
                ]
              : [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location?.name ?? '未知位置',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.current.temp,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 72,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '°',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  WeatherCode.getWeatherIcon(
                    int.tryParse(weather.current.icon) ?? 100,
                    isNight: isNight,
                  ),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  weather.current.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTempInfo('最高', '${weather.daily.first.tempMax}°'),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo('最低', '${weather.daily.first.tempMin}°'),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo('体感', '${weather.current.feelsLike}°'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '请先添加城市',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击底部导航栏"城市"添加',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(WeatherState state) {
    final weather = state.weatherData;

    if (weather == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weather.hasAlerts) ...[
            WeatherAlertCard(alerts: weather.alerts),
            const SizedBox(height: 8),
          ],
          if (state.minuteRain != null && state.minuteRain!.willRain) ...[
            _buildRainPrediction(state.minuteRain!),
            const SizedBox(height: 8),
          ],
          HourlyForecast(hourly: weather.hourly),
          const SizedBox(height: 8),
          DailyForecast(daily: weather.daily, currentWeather: weather.current),
          const SizedBox(height: 8),
          if (state.airQuality != null) ...[
            AirQualityCard(airQuality: state.airQuality!),
            const SizedBox(height: 8),
          ],
          _buildWeatherDetails(weather.current),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRainPrediction(CaiyunMinuteRain rain) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('降雨预测', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rain.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(CurrentWeather current) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '详细信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.air,
                    '风速',
                    '${current.windSpeed} km/h',
                    current.windDir,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.water_drop,
                    '湿度',
                    '${current.humidity}%',
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.visibility,
                    '能见度',
                    '${current.vis} km',
                    null,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.compress,
                    '气压',
                    '${current.pressure} hPa',
                    null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    String? subtitle,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  bool _isNightTime(String obsTime) {
    try {
      final time = DateTime.parse(obsTime);
      return time.hour < 6 || time.hour > 18;
    } catch (_) {
      return false;
    }
  }
}
