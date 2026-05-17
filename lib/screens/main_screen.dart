import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app_localizations.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../core/theme/aurora_background.dart';
import '../services/notification_service.dart';
import 'weather/weather_screen.dart';
import 'ai_assistant/ai_assistant_screen.dart';
import 'settings/settings_screen.dart';

/// 主屏幕，应用的根页面
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

/// 主屏幕状态
class _MainScreenState extends ConsumerState<MainScreen> {
  /// 是否已初始化
  bool _hasInitialized = false;

  /// 当前选中的导航索引
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  /// 初始化应用
  Future<void> _initApp() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final isFirstRun = await notificationServiceProvider.isFirstRun();

    if (isFirstRun) {
      await _requestPermissionsOnFirstRun();
      await notificationServiceProvider.markFirstRunCompleted();
    }

    await _initLocation();
  }

  /// 首次运行时请求权限
  Future<void> _requestPermissionsOnFirstRun() async {
    final hasLocationPermission = await ref
        .read(locationInitProvider.notifier)
        .requestLocationPermission();
    if (!mounted) return;

    if (!hasLocationPermission) {
      _showPermissionDialog(
        context.tr('定位权限'),
        context.tr('极光天气需要定位权限来获取您当前位置的天气信息。请在设置中授予定位权限。'),
      );
    }

    final hasNotificationPermission = await notificationServiceProvider
        .requestNotificationPermission();
    if (!mounted) return;

    if (!hasNotificationPermission) {
      _showPermissionDialog(
        context.tr('通知权限'),
        context.tr('极光天气需要通知权限来推送天气预警信息。请在设置中授予通知权限。'),
      );
    }

    await notificationServiceProvider.markNotificationPermissionRequested();
  }

  /// 显示权限请求对话框
  ///
  /// [title] 对话框标题
  /// [message] 对话框内容
  void _showPermissionDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr(title)),
        content: Text(context.tr(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('稍后设置')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(context.tr('去设置')),
          ),
        ],
      ),
    );
  }

  /// 初始化位置
  /// 天气加载由 ref.listen(locationInitProvider) 统一处理，避免重复加载
  Future<void> _initLocation() async {
    await ref.read(locationInitProvider.notifier).requestLocationPermission();
    await ref.read(locationInitProvider.notifier).initLocation();
  }

  /// 根据新的精度级别刷新位置
  ///
  /// [accuracyLevel] 位置精度级别
  Future<void> _refreshLocationWithNewAccuracy(
    LocationAccuracyLevel accuracyLevel,
  ) async {
    final defaultCity = ref.read(defaultCityProvider);
    if (defaultCity == null) return;

    final locationService = ref.read(locationServiceProvider);
    try {
      final newLocation = await locationService.getLocationFromCoords(
        defaultCity.lat,
        defaultCity.lon,
        accuracyLevel: accuracyLevel,
      );

      await ref
          .read(cityManagerProvider.notifier)
          .updateDefaultCity(newLocation);
      await ref.read(weatherProvider.notifier).loadWeather(newLocation);
    } catch (e) {
      debugPrint('刷新位置失败: $e');
    }
  }

  /// 获取屏幕列表
  ///
  /// [showAIAssistant] 是否显示天气助手
  ///
  /// 返回屏幕列表
  List<Widget> _getScreens(bool showAIAssistant) {
    return [
      const WeatherScreen(),
      if (showAIAssistant) const AIAssistantScreen(),
      const SettingsScreen(),
    ];
  }

  /// 获取导航目标列表
  ///
  /// [showAIAssistant] 是否显示天气助手
  ///
  /// 返回导航目标列表
  List<NavigationDestination> _getDestinations(
    BuildContext context,
    bool showAIAssistant,
  ) {
    return [
      NavigationDestination(
        icon: Icon(LucideIcons.cloud),
        selectedIcon: Icon(LucideIcons.cloud),
        label: context.tr('天气'),
      ),
      if (showAIAssistant)
        NavigationDestination(
          icon: Icon(LucideIcons.brain),
          selectedIcon: Icon(LucideIcons.brain),
          label: context.tr('天气助手'),
        ),
      NavigationDestination(
        icon: Icon(LucideIcons.settings),
        selectedIcon: Icon(LucideIcons.settings),
        label: context.tr('设置'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(settingsProvider);
    final weatherState = ref.watch(weatherProvider);
    final showAI = appSettings.showAIAssistant;
    final screens = _getScreens(showAI);
    final destinations = _getDestinations(context, showAI);
    final weatherData = weatherState.weatherData;
    final weatherCode = weatherData != null
        ? (int.tryParse(weatherData.current.icon) ?? 100)
        : null;

    // 监听位置初始化状态
    ref.listen(locationInitProvider, (previous, next) {
      if (next.isInitialized) {
        final defaultCity = ref.read(defaultCityProvider);
        if (defaultCity != null) {
          ref.read(weatherProvider.notifier).loadWeather(defaultCity);
        }
      }
    });

    // 监听默认城市变化
    ref.listen(defaultCityProvider, (previous, next) {
      if (next != null) {
        ref.read(weatherProvider.notifier).loadWeather(next);
      }
    });

    // 监听设置变化
    ref.listen(settingsProvider, (previous, next) {
      if (previous == null) return;

      if (previous.locationAccuracyLevel != next.locationAccuracyLevel) {
        _refreshLocationWithNewAccuracy(next.locationAccuracyLevel);
      }

      if (previous.showAIAssistant != next.showAIAssistant) {
        setState(() {
          final targetScreens = _getScreens(next.showAIAssistant);
          if (_currentIndex >= targetScreens.length) {
            _currentIndex = targetScreens.length - 1;
          }
        });
      }

      if (previous.androidLiveUpdateNotificationEnabled !=
          next.androidLiveUpdateNotificationEnabled) {
        ref
            .read(weatherProvider.notifier)
            .syncAndroidLiveUpdateNotificationWithSettings(
              scene: 'settings_changed',
            );
      }

      if (previous.appLanguage != next.appLanguage) {
        final defaultCity = ref.read(defaultCityProvider);
        if (defaultCity != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(weatherProvider.notifier).loadWeather(defaultCity);
          });
        }
      }
    });

    final scaffold = Scaffold(
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.5,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: destinations,
          ),
        ],
      ),
    );

    if (weatherCode != null) {
      return AuroraBackground(weatherCode: weatherCode, child: scaffold);
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: scaffold,
    );
  }
}
