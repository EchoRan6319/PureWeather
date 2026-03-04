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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _hasInitialized = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

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

  Future<void> _initLocation() async {
    await ref.read(locationInitProvider.notifier).requestLocationPermission();
    await ref.read(locationInitProvider.notifier).initLocation();

    final defaultCity = ref.read(defaultCityProvider);
    if (defaultCity != null) {
      await ref.read(weatherProvider.notifier).loadWeather(defaultCity);
    }
  }

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

  List<Widget> _getScreens(bool showAIAssistant) {
    return [
      const WeatherScreen(),
      if (showAIAssistant) const AIAssistantScreen(),
      const SettingsScreen(),
    ];
  }

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

    ref.listen(locationInitProvider, (previous, next) {
      if (next.isInitialized) {
        final defaultCity = ref.read(defaultCityProvider);
        if (defaultCity != null) {
          ref.read(weatherProvider.notifier).loadWeather(defaultCity);
        }
      }
    });

    ref.listen(defaultCityProvider, (previous, next) {
      if (next != null) {
        ref.read(weatherProvider.notifier).loadWeather(next);
      }
    });

    ref.listen(settingsProvider, (previous, next) {
      if (previous == null) return;

      if (previous.locationAccuracyLevel != next.locationAccuracyLevel) {
        _refreshLocationWithNewAccuracy(next.locationAccuracyLevel);
      }

      // Handle AI Assistant toggle index shift
      if (previous.showAIAssistant != next.showAIAssistant) {
        setState(() {
          if (next.showAIAssistant) {
            // If AI Assistant is enabled, and we were on Settings (index 1), shift to 2
            if (_currentIndex == 1) {
              _currentIndex = 2;
            }
          } else {
            // If AI Assistant is disabled
            if (_currentIndex == 1) {
              // If we were on AI Assistant, switch to Weather
              _currentIndex = 0;
            } else if (_currentIndex == 2) {
              // If we were on Settings, shift to 1
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
