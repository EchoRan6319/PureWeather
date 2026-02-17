import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weather_models.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../services/caiyun_service.dart';
import '../../services/location_service.dart';
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

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CitySelectorSheet(
        onCitySelected: (location, {bool isLocated = false}) async {
          Navigator.pop(context);
          await ref
              .read(cityManagerProvider.notifier)
              .addCityAndSetDefault(location, isLocated: isLocated);
          await ref.read(weatherProvider.notifier).loadWeather(location);
        },
      ),
    );
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_location_outlined),
                  onPressed: _showCitySelector,
                  tooltip: '添加城市',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildCurrentWeather(
                  weatherState,
                  defaultCity,
                  ref.watch(settingsProvider),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildContent(weatherState)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(
    WeatherState state,
    Location? location,
    AppSettings settings,
  ) {
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

    final todayDaily = weather.daily.isNotEmpty ? weather.daily.first : null;
    final isNight = _isNightTime(
      weather.current.obsTime,
      todayDaily?.sunrise,
      todayDaily?.sunset,
    );

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (location?.isLocated == true) ...[
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  location?.name ?? '未知位置',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WeatherCode.convertTemperature(
                    weather.current.temp,
                    toFahrenheit: settings.temperatureUnit == 'fahrenheit',
                  ),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 72,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    settings.temperatureUnit == 'fahrenheit' ? '°F' : '°',
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
                _buildTempInfo(
                  '最高',
                  '${WeatherCode.convertTemperature(weather.daily.first.tempMax, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo(
                  '最低',
                  '${WeatherCode.convertTemperature(weather.daily.first.tempMin, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo(
                  '体感',
                  '${WeatherCode.convertTemperature(weather.current.feelsLike, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
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
      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weather.hasAlerts) ...[
            WeatherAlertCard(alerts: weather.alerts),
            const SizedBox(height: 6),
          ],
          if (state.minuteRain != null && state.minuteRain!.willRain) ...[
            _buildRainPrediction(state.minuteRain!),
            const SizedBox(height: 6),
          ],
          HourlyForecast(
            hourly: weather.hourly,
            sunrise: weather.daily.isNotEmpty
                ? weather.daily.first.sunrise
                : null,
            sunset: weather.daily.isNotEmpty
                ? weather.daily.first.sunset
                : null,
            temperatureUnit: ref.watch(settingsProvider).temperatureUnit,
          ),
          const SizedBox(height: 6),
          DailyForecast(
            daily: weather.daily,
            currentWeather: weather.current,
            sunrise: weather.daily.isNotEmpty
                ? weather.daily.first.sunrise
                : null,
            sunset: weather.daily.isNotEmpty
                ? weather.daily.first.sunset
                : null,
            temperatureUnit: ref.watch(settingsProvider).temperatureUnit,
          ),
          const SizedBox(height: 6),
          if (state.airQuality != null) ...[
            AirQualityCard(airQuality: state.airQuality!),
            const SizedBox(height: 6),
          ],
          _buildWeatherDetails(
            weather.current,
            weather.daily.isNotEmpty ? weather.daily.first : null,
          ),
          const SizedBox(height: 6),
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

  Widget _buildWeatherDetails(
    CurrentWeather current,
    DailyWeather? todayDaily,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 10),
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
                Expanded(
                  child: todayDaily != null
                      ? _buildDetailItem(
                          Icons.wb_twilight,
                          '日出',
                          todayDaily.sunrise,
                          null,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                Expanded(
                  child: todayDaily != null
                      ? _buildDetailItem(
                          Icons.nights_stay,
                          '日落',
                          todayDaily.sunset,
                          null,
                        )
                      : const SizedBox(),
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

  bool _isNightTime(String obsTime, String? sunrise, String? sunset) {
    try {
      final now = DateTime.parse(obsTime);

      if (sunrise != null &&
          sunset != null &&
          sunrise.isNotEmpty &&
          sunset.isNotEmpty) {
        final sunriseTime = _parseTime(sunrise, now);
        final sunsetTime = _parseTime(sunset, now);

        if (sunriseTime != null && sunsetTime != null) {
          return now.isBefore(sunriseTime) || now.isAfter(sunsetTime);
        }
      }

      return now.hour < 6 || now.hour >= 18;
    } catch (_) {
      return false;
    }
  }

  DateTime? _parseTime(String time, DateTime baseDate) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          hour,
          minute,
        );
      }
    } catch (_) {}
    return null;
  }
}

class _CitySelectorSheet extends ConsumerStatefulWidget {
  final Function(Location, {bool isLocated}) onCitySelected;

  const _CitySelectorSheet({required this.onCitySelected});

  @override
  ConsumerState<_CitySelectorSheet> createState() => _CitySelectorSheetState();
}

class _CitySelectorSheetState extends ConsumerState<_CitySelectorSheet> {
  final _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final results = await locationService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
        );
        widget.onCitySelected(location, isLocated: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法获取位置，请检查权限设置'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('定位失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _buildSubtitle(String adm1, String adm2) {
    final parts = <String>[];
    if (adm1.isNotEmpty) parts.add(adm1);
    if (adm2.isNotEmpty && adm2 != adm1) parts.add(adm2);
    return parts.isEmpty ? '' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(cityManagerProvider);
    final defaultCity = ref.watch(defaultCityProvider);

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索城市',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        _searchCities(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('定位当前位置'),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildCityList(cities, defaultCity, scrollController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(location.name),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              widget.onCitySelected(location);
            },
          ),
        );
      },
    );
  }

  Widget _buildCityList(
    List<Location> cities,
    Location? defaultCity,
    ScrollController scrollController,
  ) {
    if (cities.isEmpty) {
      return Center(
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
              '还没有添加城市',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '搜索城市或使用定位添加',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final sortedCities = [...cities]
      ..sort((a, b) {
        if (a.isLocated) return -1;
        if (b.isLocated) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedCities.length,
      itemBuilder: (context, index) {
        final city = sortedCities[index];
        final isDefault = city.id == defaultCity?.id;
        final isLocated = city.isLocated;
        final weatherAsync = ref.watch(weatherForCityProvider(city));

        return Card(
          color: isDefault
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          child: ListTile(
            leading: Icon(
              isLocated ? Icons.location_on : Icons.star_outline,
              color: isDefault
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              city.name,
              style: isDefault
                  ? const TextStyle(fontWeight: FontWeight.w600)
                  : null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                weatherAsync.when(
                  data: (weather) {
                    if (weather == null) return const SizedBox();
                    final settings = ref.watch(settingsProvider);
                    final convertedTemp = WeatherCode.convertTemperature(
                      weather.current.temp,
                      toFahrenheit: settings.temperatureUnit == 'fahrenheit',
                    );
                    final unit = settings.temperatureUnit == 'fahrenheit'
                        ? '°F'
                        : '°';
                    return Text(
                      '$convertedTemp$unit',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
                if (!isLocated) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () async {
                      await ref
                          .read(cityManagerProvider.notifier)
                          .removeCity(city.id);
                    },
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ],
            ),
            onTap: () async {
              await ref
                  .read(cityManagerProvider.notifier)
                  .setDefaultCity(city.id);
              await ref.read(weatherProvider.notifier).loadWeather(city);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
