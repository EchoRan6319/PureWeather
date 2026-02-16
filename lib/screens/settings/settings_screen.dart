import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSectionHeader(context, '外观'),
          _buildThemeSection(context, ref, themeSettings),
          const Divider(),
          _buildSectionHeader(context, '功能'),
          _buildFeaturesSection(context, ref, appSettings),
          const Divider(),
          _buildSectionHeader(context, '关于'),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('主题模式'),
          subtitle: Text(_getThemeModeName(settings.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeModeDialog(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('主题颜色'),
          subtitle: Text(settings.useDynamicColor ? '跟随壁纸' : '自定义颜色'),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: settings.seedColor ?? AppTheme.presetSeedColors.first,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          onTap: () => _showColorPickerDialog(context, ref, settings),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.wallpaper_outlined),
          title: const Text('动态取色'),
          subtitle: const Text('根据壁纸自动生成主题色'),
          value: settings.useDynamicColor,
          onChanged: (value) {
            ref.read(themeProvider.notifier).setUseDynamicColor(value);
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.swipe_outlined),
          title: const Text('预测式返回手势'),
          subtitle: const Text('在返回时显示预览动画（需要Android 14+）'),
          value: settings.predictiveBackEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setPredictiveBackEnabled(value);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('天气预警通知'),
          subtitle: const Text('接收极端天气预警推送'),
          value: settings.notificationsEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.refresh_outlined),
          title: const Text('自动刷新'),
          subtitle: Text('每${settings.refreshInterval}分钟自动更新天气'),
          value: settings.autoRefreshEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setAutoRefreshEnabled(value);
          },
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('刷新间隔'),
          subtitle: Text('${settings.refreshInterval}分钟'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showRefreshIntervalDialog(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: const Text('位置显示'),
          subtitle: Text(
            settings.locationAccuracyLevel == LocationAccuracyLevel.street
                ? '展示附近地标/街道'
                : '展示区/县',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLocationAccuracyDialog(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.thermostat_outlined),
          title: const Text('温度单位'),
          subtitle: Text(settings.temperatureUnit == 'celsius' ? '摄氏度' : '华氏度'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTemperatureUnitDialog(context, ref, settings),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于轻氧天气'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAboutDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('用户协议'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.update_outlined),
          title: const Text('检查更新'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已是最新版本'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  String _getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  void _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                }
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择主题颜色'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: AppTheme.presetSeedColors.map((color) {
              final isSelected =
                  settings.seedColor?.toARGB32() == color.toARGB32();
              return InkWell(
                onTap: () {
                  ref.read(themeProvider.notifier).setSeedColor(color);
                  ref.read(themeProvider.notifier).setUseDynamicColor(false);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color:
                              ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(themeProvider.notifier).setSeedColor(null);
              Navigator.pop(ctx);
            },
            child: const Text('重置'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showRefreshIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final intervals = [15, 30, 60, 120];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刷新间隔'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return RadioListTile<int>(
              title: Text('$interval 分钟'),
              value: interval,
              groupValue: settings.refreshInterval,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setRefreshInterval(value);
                }
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTemperatureUnitDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('温度单位'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('摄氏度 (°C)'),
              value: 'celsius',
              groupValue: settings.temperatureUnit,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setTemperatureUnit(value);
                }
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('华氏度 (°F)'),
              value: 'fahrenheit',
              groupValue: settings.temperatureUnit,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setTemperatureUnit(value);
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationAccuracyDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('位置显示'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<LocationAccuracyLevel>(
              title: const Text('展示区/县'),
              subtitle: const Text('定位到行政区级别'),
              value: LocationAccuracyLevel.district,
              groupValue: settings.locationAccuracyLevel,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .setLocationAccuracyLevel(value);
                }
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<LocationAccuracyLevel>(
              title: const Text('展示附近地标/街道'),
              subtitle: const Text('精确定位到街道级别'),
              value: LocationAccuracyLevel.street,
              groupValue: settings.locationAccuracyLevel,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .setLocationAccuracyLevel(value);
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '轻氧天气',
      applicationVersion: '2.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.wb_cloudy,
          size: 32,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: [
        const Text('一款简洁美观的天气应用'),
        const SizedBox(height: 8),
        const Text('使用 Material You Design 设计语言'),
        const SizedBox(height: 8),
        const Text('数据来源：和风天气、彩云天气'),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse('https://github.com/EchoRan/LvDongWeather'),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(
            'https://github.com/EchoRan/LvDongWeather',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
