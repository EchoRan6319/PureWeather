import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../app_localizations.dart';
import '../../models/weather_models.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/caiyun_service.dart';
import '../../widgets/hourly_forecast.dart';
import '../../widgets/daily_forecast.dart';
import '../../widgets/weather_alert_card.dart';
import '../../widgets/air_quality_card.dart';
import '../../widgets/weather_indices_card.dart';

/// 天气主页面
///
/// 显示当前天气信息、天气预报和相关数据
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // 页面加载后获取天气数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  /// 加载天气数据
  Future<void> _loadWeather() async {
    final defaultCity = ref.read(defaultCityProvider);
    if (defaultCity != null) {
      await ref.read(weatherProvider.notifier).loadWeather(defaultCity);
    }
  }

  /// 刷新天气数据
  Future<void> _onRefresh() async {
    await ref.read(weatherProvider.notifier).refresh();
  }

  /// 显示城市选择器
  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
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

    // 监听默认城市变化，自动加载新城市的天气
    ref.listen(defaultCityProvider, (previous, next) {
      if (next != null) {
        ref.read(weatherProvider.notifier).loadWeather(next);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;

        final scaffoldBody = RefreshIndicator(
          onRefresh: _onRefresh,
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 900 : double.infinity,
                      ),
                      child: _buildCurrentWeather(
                        weatherState,
                        defaultCity,
                        ref.watch(settingsProvider),
                        viewportHeight: constraints.maxHeight,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 900 : double.infinity,
                      ),
                      child: _buildContent(weatherState),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return Scaffold(body: scaffoldBody);
      },
    );
  }

  /// 构建当前天气显示
  ///
  /// [state]: 天气状态
  /// [location]: 位置信息
  /// [settings]: 应用设置
  Widget _buildCurrentWeather(
    WeatherState state,
    Location? location,
    AppSettings settings, {
    required double viewportHeight,
  }) {
    // 加载中状态
    if (state.isLoading && state.weatherData == null) {
      return Container(
        color: Colors.transparent,
        child: const SizedBox.shrink(),
      );
    }

    final weather = state.weatherData;
    if (weather == null) {
      if (state.errorMessage != null) {
        return _buildErrorState(
          state.errorMessage!,
          viewportHeight: viewportHeight,
        );
      }
      return _buildEmptyState(viewportHeight: viewportHeight);
    }

    // 获取今日天气和昼夜状态
    final todayDaily = weather.daily.isNotEmpty ? weather.daily.first : null;
    final isNight = _isNightTime(
      weather.current.obsTime,
      todayDaily?.sunrise,
      todayDaily?.sunset,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 0,
          top: 12 + MediaQuery.of(context).padding.top,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 城市名称
            Stack(
              alignment: Alignment.center,
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
                      location?.name ?? context.tr('未知位置'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.navigation_outlined),
                    onPressed: _showCitySelector,
                    tooltip: context.tr('导航'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 当前温度
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
            // 天气状态
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
                  context.tr(weather.current.text),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 温度信息
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTempInfo(
                  context.tr('最高'),
                  '${WeatherCode.convertTemperature(weather.daily.first.tempMax, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo(
                  context.tr('最低'),
                  '${WeatherCode.convertTemperature(weather.daily.first.tempMin, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.outline,
                ),
                _buildTempInfo(
                  context.tr('体感'),
                  '${WeatherCode.convertTemperature(weather.current.feelsLike, toFahrenheit: settings.temperatureUnit == 'fahrenheit')}${settings.temperatureUnit == 'fahrenheit' ? '°F' : '°'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建温度信息项
  ///
  /// [label]: 标签
  /// [value]: 值
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

  /// 构建错误状态
  ///
  /// [message]: 错误信息
  Widget _buildErrorState(String message, {required double viewportHeight}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: viewportHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: colorScheme.surfaceContainer),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _buildEmptyStateAction(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('加载天气失败'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.tr('重试')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({required double viewportHeight}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: viewportHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: colorScheme.surfaceContainer),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _buildEmptyStateAction(),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('请先添加城市'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('点击右上角“导航”按钮手动添加城市'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateAction() {
    return IconButton.filledTonal(
      onPressed: _showCitySelector,
      tooltip: context.tr('导航'),
      icon: const Icon(Icons.navigation_outlined),
    );
  }

  /// 构建天气详情内容
  ///
  /// [state]: 天气状态
  Widget _buildContent(WeatherState state) {
    final weather = state.weatherData;
    if (weather == null) return const SizedBox.shrink();

    final settings = ref.watch(settingsProvider);
    final order = settings.weatherCardOrder;
    final normalizedOrder = order.contains('hourly')
        ? order
        : ['hourly', ...order];

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 天气预警（固定位置，不参与排序）
          if (weather.hasAlerts) ...[
            _buildAlertSlot(weather),
            const SizedBox(height: 12),
          ],
          // 降雨预测
          if (state.minuteRain != null && state.minuteRain!.willRain) ...[
            _buildRainPrediction(state.minuteRain!),
            const SizedBox(height: 12),
          ],
          // 根据设置的顺序显示天气卡片
          ...normalizedOrder.map((key) {
            Widget? card;
            switch (key) {
              case 'hourly':
                card = HourlyForecast(
                  hourly: weather.hourly,
                  sunrise: weather.daily.isNotEmpty
                      ? weather.daily.first.sunrise
                      : null,
                  sunset: weather.daily.isNotEmpty
                      ? weather.daily.first.sunset
                      : null,
                  nextSunrise: weather.daily.length > 1
                      ? weather.daily[1].sunrise
                      : null,
                  temperatureUnit: settings.temperatureUnit,
                );
                break;
              case 'daily':
                card = DailyForecast(
                  daily: weather.daily,
                  currentWeather: weather.current,
                  sunrise: weather.daily.isNotEmpty
                      ? weather.daily.first.sunrise
                      : null,
                  sunset: weather.daily.isNotEmpty
                      ? weather.daily.first.sunset
                      : null,
                  temperatureUnit: settings.temperatureUnit,
                );
                break;
              case 'airQuality':
                if (state.airQuality != null) {
                  card = AirQualityCard(airQuality: state.airQuality!);
                }
                break;
              case 'details':
                card = _buildWeatherDetails(
                  weather.current,
                  weather.daily.isNotEmpty ? weather.daily.first : null,
                );
                break;
              case 'indices':
                if (state.weatherIndices != null &&
                    state.weatherIndices!.isNotEmpty) {
                  card = WeatherIndicesCard(indices: state.weatherIndices!);
                }
                break;
            }

            if (card == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            );
          }),
        ],
      ),
    );
  }

  /// 构建降雨预测卡片
  ///
  /// [rain]: 降雨预测数据
  Widget _buildRainPrediction(CaiyunMinuteRain rain) {
    return Container(
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
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
                Text(
                  context.tr('降雨预测'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(rain.description),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建天气预警卡片（固定位置）
  Widget _buildAlertSlot(WeatherData weather) {
    return WeatherAlertCard(alerts: weather.alerts);
  }

  /// 构建天气详情卡片
  ///
  /// [current]: 当前天气
  /// [todayDaily]: 今日天气
  Widget _buildWeatherDetails(
    CurrentWeather current,
    DailyWeather? todayDaily,
  ) {
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
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('详细信息'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 第一行详情
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.air,
                    context.tr(current.windDir),
                    context.tr('{value}级', args: {'value': current.windScale}),
                    null,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.water_drop,
                    context.tr('湿度'),
                    '${current.humidity}%',
                    null,
                  ),
                ),
                Expanded(
                  child: todayDaily != null
                      ? _buildDetailItem(
                          Icons.wb_twilight,
                          context.tr('日出'),
                          todayDaily.sunrise,
                          null,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 第二行详情
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.visibility,
                    context.tr('能见度'),
                    '${current.vis} km',
                    null,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.compress,
                    context.tr('气压'),
                    '${current.pressure} hPa',
                    null,
                  ),
                ),
                Expanded(
                  child: todayDaily != null
                      ? _buildDetailItem(
                          Icons.nights_stay,
                          context.tr('日落'),
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

  /// 构建详情项
  ///
  /// [icon]: 图标
  /// [label]: 标签
  /// [value]: 值
  /// [subtitle]: 副标题
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

  /// 判断是否为夜间
  ///
  /// [obsTime]: 观测时间
  /// [sunrise]: 日出时间
  /// [sunset]: 日落时间
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

      // 默认规则：6点前或18点后为夜间
      return now.hour < 6 || now.hour >= 18;
    } catch (_) {
      return false;
    }
  }

  /// 解析时间字符串
  ///
  /// [time]: 时间字符串 (HH:MM)
  /// [baseDate]: 基础日期
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

/// 城市选择器底部弹窗
///
/// 用于搜索和选择城市
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

  /// 搜索城市
  ///
  /// [query]: 搜索关键词
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

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final accuracyLevel = ref.read(settingsProvider).locationAccuracyLevel;
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
          accuracyLevel: accuracyLevel,
        );
        widget.onCitySelected(location, isLocated: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('无法获取位置，请检查权限设置')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('定位失败: {error}', args: {'error': e})),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _confirmRemoveCity(Location city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('删除城市')),
        content: Text(context.tr('确定删除 {city} 吗？', args: {'city': city.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('取消')),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('删除')),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(cityManagerProvider);
    final defaultCity = ref.watch(defaultCityProvider);
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    const topExtraClearance = 30.0;
    final topSafeOffset = topInset + topExtraClearance;
    final sheetMax =
        ((mediaQuery.size.height - topSafeOffset) / mediaQuery.size.height)
            .clamp(0.5, 0.92)
            .toDouble();
    final sheetInitial = sheetMax < 0.6 ? sheetMax : 0.6;
    final sheetMin = sheetInitial < 0.4 ? sheetInitial : 0.4;

    return Padding(
      padding: EdgeInsets.only(
        top: topSafeOffset,
        left: mediaQuery.viewPadding.left,
        right: mediaQuery.viewPadding.right,
      ),
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        duration: const Duration(milliseconds: 100),
        child: DraggableScrollableSheet(
          initialChildSize: sheetInitial,
          minChildSize: sheetMin,
          maxChildSize: sheetMax,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 拖拽指示器
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.uiTokens.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 搜索栏和定位按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: context.tr('搜索城市'),
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
                          label: Text(context.tr('定位当前位置')),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 搜索结果或城市列表
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
      ),
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.uiTokens.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.uiTokens.cardBorder),
          ),
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(location.name),
            subtitle: Text(
              '${location.lat.toStringAsFixed(2)}, ${location.lon.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: FilledButton.tonal(
              onPressed: () => widget.onCitySelected(location),
              child: Text(context.tr('添加')),
            ),
          ),
        );
      },
    );
  }

  /// 构建城市列表
  ///
  /// [cities]: 城市列表
  /// [defaultCity]: 默认城市
  /// [scrollController]: 滚动控制器
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
              context.tr('还没有添加城市'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('搜索城市或使用定位添加'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 排序城市：定位城市优先，然后按排序序号
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDefault
                ? context.uiTokens.selectedBackground
                : context.uiTokens.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDefault
                  ? context.uiTokens.selectedBorder
                  : context.uiTokens.cardBorder,
            ),
          ),
          child: ListTile(
            leading: Icon(
              isDefault
                  ? Icons.check_circle_rounded
                  : (isLocated
                        ? Icons.my_location_rounded
                        : Icons.location_on_outlined),
              color: isDefault
                  ? context.uiTokens.selectedBorder
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    city.name,
                    style: isDefault
                        ? const TextStyle(fontWeight: FontWeight.w600)
                        : null,
                  ),
                ),
                if (isLocated) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.uiTokens.selectedForeground.withValues(
                        alpha: 0.14,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.uiTokens.selectedBorder.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          size: 14,
                          color: context.uiTokens.selectedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('定位'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: context.uiTokens.selectedForeground,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.uiTokens.selectedForeground.withValues(
                        alpha: 0.14,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.uiTokens.selectedBorder.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    child: Text(
                      context.tr('默认'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.uiTokens.selectedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 显示城市当前温度
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
                  error: (error, stackTrace) => const SizedBox(),
                ),
                // 删除按钮
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final confirmed = await _confirmRemoveCity(city);
                    if (!confirmed) {
                      return;
                    }

                    await ref
                        .read(cityManagerProvider.notifier)
                        .removeCity(city.id);

                    // 如果所有城市都被删除，自动重新初始化位置
                    final cities = ref.read(cityManagerProvider);
                    if (cities.isEmpty) {
                      await ref
                          .read(locationInitProvider.notifier)
                          .initLocation(force: true);

                      final locationState = ref.read(locationInitProvider);
                      if (locationState.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.tr('已删除全部城市，定位失败。请搜索城市或检查定位权限。'),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            // 点击切换默认城市
            onTap: () async {
              await ref
                  .read(cityManagerProvider.notifier)
                  .setDefaultCity(city.id);
              await ref.read(weatherProvider.notifier).loadWeather(city);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
