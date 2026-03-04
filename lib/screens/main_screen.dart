import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
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
    final hasLocationPermission =
        await ref
            .read(locationInitProvider.notifier)
            .requestLocationPermission();

    if (!hasLocationPermission) {
      _showPermissionDialog(
        '定位权限',
        '轻氧天气需要定位权限来获取您当前位置的天气信息。请在设置中授予定位权限。',
      );
    }

    final hasNotificationPermission = await notificationServiceProvider
        .requestNotificationPermission();

    if (!hasNotificationPermission) {
      _showPermissionDialog(
        '通知权限',
        '轻氧天气需要通知权限来推送天气预警信息。请在设置中授予通知权限。',
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
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('稍后设置'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: const Text('去设置'),
              ),
            ],
          ),
    );
  }

  /// 初始化位置
  Future<void> _initLocation() async {
    await ref.read(locationInitProvider.notifier).requestLocationPermission();
    await ref.read(locationInitProvider.notifier).initLocation();

    final defaultCity = ref.read(defaultCityProvider);
    if (defaultCity != null) {
      await ref.read(weatherProvider.notifier).loadWeather(defaultCity);
    }
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
  /// [showAIAssistant] 是否显示AI助手
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
  /// [showAIAssistant] 是否显示AI助手
  /// 
  /// 返回导航目标列表
  List<NavigationDestination> _getDestinations(bool showAIAssistant) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.wb_cloudy_outlined),
        selectedIcon: Icon(Icons.wb_cloudy),
        label: '天气',
      ),
      if (showAIAssistant)
        const NavigationDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology),
          label: 'AI助手',
        ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: '设置',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(settingsProvider);
    final showAI = appSettings.showAIAssistant;
    final screens = _getScreens(showAI);
    final destinations = _getDestinations(showAI);

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

      // 处理位置精度变化
      if (previous.locationAccuracyLevel != next.locationAccuracyLevel) {
        _refreshLocationWithNewAccuracy(next.locationAccuracyLevel);
      }

      // 处理AI助手开关状态变化
      if (previous.showAIAssistant != next.showAIAssistant) {
        setState(() {
          if (next.showAIAssistant) {
            // 如果AI助手启用，且当前在设置页面(索引1)，则切换到索引2
            if (_currentIndex == 1) {
              _currentIndex = 2;
            }
          } else {
            // 如果AI助手禁用
            if (_currentIndex == 1) {
              // 如果当前在AI助手页面，切换到天气页面
              _currentIndex = 0;
            } else if (_currentIndex == 2) {
              // 如果当前在设置页面，切换到索引1
              _currentIndex = 1;
            }
          }
        });
      }
    });

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
