import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_icon.dart';
import 'scheduled_broadcast_screen.dart';
import 'card_order_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _SettingsSection(
            title: '个性化',
            icon: Icons.palette_outlined,
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                title: '主题模式',
                subtitle: _getThemeModeName(themeSettings.themeMode),

                onTap: () => _showThemeModeDialog(context, ref, themeSettings),
              ),
              _SettingsTile(
                icon: Icons.color_lens_outlined,
                title: '主题颜色',
                subtitle: themeSettings.useDynamicColor ? '跟随壁纸' : '自定义颜色',
                trailing: _ColorPreview(
                  color:
                      themeSettings.seedColor ??
                      AppTheme.presetSeedColors.first,
                ),
                onTap: () =>
                    _showColorPickerDialog(context, ref, themeSettings),
              ),
              _SettingsSwitch(
                icon: Icons.wallpaper_outlined,
                title: '动态取色',
                subtitle: '根据壁纸自动生成主题色（ColorOS设备建议关闭此选项，否则会导致应用配色异常）',
                value: themeSettings.useDynamicColor,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setUseDynamicColor(value);
                },
              ),
              _SettingsSwitch(
                icon: Icons.font_download_outlined,
                title: '内置字体 (OPPO Sans)',
                subtitle: '启用后可解决部分ColorOS设备系统的字体显示问题',
                value: themeSettings.useCustomFont,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setUseCustomFont(value);
                },
              ),
            ],
          ),
          _SettingsSection(
            title: '通知',
            icon: Icons.notifications_outlined,
            children: [
              _SettingsSwitch(
                icon: Icons.warning_amber_outlined,
                title: '天气预警通知',
                subtitle: '接收极端天气预警推送',
                value: appSettings.notificationsEnabled,
                onChanged: (value) async {
                  if (value) {
                    final hasPermission = await notificationServiceProvider
                        .requestNotificationPermission();
                    if (!hasPermission) {
                      if (context.mounted) {
                        _showPermissionDeniedDialog(context);
                      }
                      return;
                    }
                  }
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(value);
                },
              ),
              _SettingsTile(
                icon: Icons.schedule_outlined,
                title: '定时播报',
                subtitle: '设置每日定时推送天气信息',
                onTap: () => ScheduledBroadcastScreen.show(context, ref),
              ),
            ],
          ),
          _SettingsSection(
            title: '显示',
            icon: Icons.visibility_outlined,
            children: [
              _SettingsSwitch(
                icon: Icons.psychology_outlined,
                title: '显示 AI 助手',
                subtitle: '在底部导航栏显示 AI 助手页面',
                value: appSettings.showAIAssistant,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setShowAIAssistant(value);
                },
              ),
              _SettingsTile(
                icon: Icons.device_thermostat_outlined,
                title: '温度单位',
                subtitle: appSettings.temperatureUnit == 'celsius'
                    ? '摄氏度 (°C)'
                    : '华氏度 (°F)',
                onTap: () =>
                    _showTemperatureUnitDialog(context, ref, appSettings),
              ),
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: '位置显示精度',
                subtitle:
                    appSettings.locationAccuracyLevel ==
                        LocationAccuracyLevel.street
                    ? '街道级别'
                    : '区县级别',
                onTap: () =>
                    _showLocationAccuracyDialog(context, ref, appSettings),
              ),
              _SettingsTile(
                icon: Icons.sort_rounded,
                title: '天气卡片排序',
                subtitle: '自定义天气详情页卡片显示顺序',
                onTap: () => CardOrderScreen.show(context),
              ),
            ],
          ),
          _SettingsSection(
            title: '数据',
            icon: Icons.sync_outlined,
            children: [
              _SettingsSwitch(
                icon: Icons.autorenew_outlined,
                title: '自动刷新',
                subtitle: '每 ${appSettings.refreshInterval} 分钟自动更新',
                value: appSettings.autoRefreshEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setAutoRefreshEnabled(value);
                },
              ),
              _SettingsTile(
                icon: Icons.timer_outlined,
                title: '刷新间隔',
                subtitle: '${appSettings.refreshInterval} 分钟',
                onTap: () =>
                    _showRefreshIntervalDialog(context, ref, appSettings),
              ),
            ],
          ),
          _SettingsSection(
            title: '高级',
            icon: Icons.tune_outlined,
            children: [
              _SettingsSwitch(
                icon: Icons.swipe_outlined,
                title: '预测式返回手势',
                subtitle: '返回时显示预览动画（Android 14+）',
                value: appSettings.predictiveBackEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setPredictiveBackEnabled(value);
                },
              ),
            ],
          ),
          _SettingsSection(
            title: '关于',
            icon: Icons.info_outline,
            children: [
              _SettingsTile(
                icon: Icons.apps_outlined,
                title: '关于轻氧天气',
                onTap: () => _showAboutDialog(context),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () => _showPrivacyPolicy(context),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: () => _showUserAgreement(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectionBottomSheet(
        title: '主题模式',
        items: AppThemeMode.values.map(
          (mode) => _SelectionItem(
            title: _getThemeModeName(mode),
            icon: _getThemeModeIcon(mode),
            isSelected: settings.themeMode == mode,
            onTap: () {
              ref.read(themeProvider.notifier).setThemeMode(mode);
              Navigator.pop(ctx);
            },
          ),
        ),
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto_outlined;
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  void _showColorPickerDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    Color selectedColor = settings.seedColor ?? AppTheme.presetSeedColors.first;
    final hexController = TextEditingController(
      text:
          '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                _buildBottomSheetHandle(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    '选择主题颜色',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildDynamicColorSection(context, ref, settings),
                      const SizedBox(height: 20),
                      _buildSectionTitle(context, '预设颜色'),
                      const SizedBox(height: 12),
                      _buildPresetColors(context, settings, selectedColor, (
                        color,
                      ) {
                        setState(() {
                          selectedColor = color;
                          hexController.text =
                              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                        });
                      }),
                      const SizedBox(height: 20),
                      _buildSectionTitle(context, '自定义颜色'),
                      const SizedBox(height: 12),
                      _buildCustomColorPicker(
                        context,
                        selectedColor,
                        hexController,
                        (color) {
                          setState(() {
                            selectedColor = color;
                            hexController.text =
                                '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildHexInputSection(context, hexController, (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      }),
                      const SizedBox(height: 24),
                      _buildSelectedColorPreview(context, selectedColor),
                      const SizedBox(height: 24),
                      _buildActionButtons(
                        context,
                        ref,
                        ctx,
                        selectedColor,
                        settings,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDynamicColorSection(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final isSupported = lightDynamic != null;
        final dynamicColor = lightDynamic?.primary;
        final isCurrentDynamic = settings.useDynamicColor;

        if (!isSupported) {
          return _buildDynamicColorNotSupported(context);
        }

        return _SettingsCard(
          child: InkWell(
            onTap: () {
              ref.read(themeProvider.notifier).setUseDynamicColor(true);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: dynamicColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrentDynamic
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (dynamicColor ?? Colors.grey).withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '壁纸取色',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '检测颜色: #${dynamicColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentDynamic)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicColorNotSupported(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '动态取色不可用',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '可能原因：\n• 设备系统版本低于 Android 12\n• 设备制造商禁用了动态取色\n• 系统设置中未启用 Material You',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetColors(
    BuildContext context,
    ThemeSettings settings,
    Color selectedColor,
    Function(Color) onColorSelected,
  ) {
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: AppTheme.presetSeedColors.map((color) {
            final isSelected = selectedColor.toARGB32() == color.toARGB32();
            return InkWell(
              onTap: () => onColorSelected(color),
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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
    );
  }

  Widget _buildCustomColorPicker(
    BuildContext context,
    Color selectedColor,
    TextEditingController hexController,
    Function(Color) onColorSelected,
  ) {
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ColorPicker(
          pickerColor: selectedColor,
          onColorChanged: onColorSelected,
          pickerAreaHeightPercent: 0.6,
          enableAlpha: false,
          labelTypes: const [],
          portraitOnly: true,
          pickerAreaBorderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHexInputSection(
    BuildContext context,
    TextEditingController hexController,
    Function(Color) onColorParsed,
  ) {
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '十六进制颜色代码',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hexController,
              decoration: InputDecoration(
                hintText: '#RRGGBB',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      hexController.text = data!.text!;
                      _parseHexColor(hexController.text, onColorParsed);
                    }
                  },
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
              ],
              onChanged: (value) {
                _parseHexColor(value, onColorParsed);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _parseHexColor(String hex, Function(Color) onColorParsed) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      try {
        final color = Color(int.parse('FF$cleanHex', radix: 16));
        onColorParsed(color);
      } catch (_) {}
    }
  }

  Widget _buildSelectedColorPreview(BuildContext context, Color color) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );

    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预览效果',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '主色',
                      style: TextStyle(color: colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '次色',
                      style: TextStyle(color: colorScheme.onSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '三色',
                      style: TextStyle(color: colorScheme.onTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BuildContext dialogContext,
    Color selectedColor,
    ThemeSettings settings,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              ref.read(themeProvider.notifier).setSeedColor(null);
              ref.read(themeProvider.notifier).setUseDynamicColor(true);
              Navigator.pop(dialogContext);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('重置'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () {
              ref.read(themeProvider.notifier).setSeedColor(selectedColor);
              ref.read(themeProvider.notifier).setUseDynamicColor(false);
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('应用'),
          ),
        ),
      ],
    );
  }

  void _showRefreshIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final intervals = [15, 30, 60, 120];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectionBottomSheet(
        title: '刷新间隔',
        items: intervals.map(
          (interval) => _SelectionItem(
            title: '$interval 分钟',
            icon: Icons.timer_outlined,
            isSelected: settings.refreshInterval == interval,
            onTap: () {
              ref.read(settingsProvider.notifier).setRefreshInterval(interval);
              Navigator.pop(ctx);
            },
          ),
        ),
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showTemperatureUnitDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final units = [
      ('celsius', '摄氏度', '°C', '温度显示为摄氏度', Icons.device_thermostat_outlined),
      ('fahrenheit', '华氏度', '°F', '温度显示为华氏度', Icons.thermostat_outlined),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectionBottomSheet(
        title: '温度单位',
        items: units.map(
          (unit) => _SelectionItem(
            title: '${unit.$2} (${unit.$3})',
            subtitle: unit.$4,
            icon: unit.$5,
            isSelected: settings.temperatureUnit == unit.$1,
            onTap: () {
              ref.read(settingsProvider.notifier).setTemperatureUnit(unit.$1);
              Navigator.pop(ctx);
            },
          ),
        ),
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showLocationAccuracyDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final options = [
      (
        LocationAccuracyLevel.district,
        '展示区/县',
        '定位到行政区级别',
        Icons.location_city,
      ),
      (
        LocationAccuracyLevel.street,
        '展示附近地标/街道',
        '精确定位到街道级别',
        Icons.location_on_outlined,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectionBottomSheet(
        title: '位置显示',
        items: options.map(
          (option) => _SelectionItem(
            title: option.$2,
            subtitle: option.$3,
            icon: option.$4,
            isSelected: settings.locationAccuracyLevel == option.$1,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setLocationAccuracyLevel(option.$1);
              Navigator.pop(ctx);
            },
          ),
        ),
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('需要通知权限'),
        content: const Text('轻氧天气需要通知权限才能推送天气预警。请在系统设置中授予通知权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
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

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AboutBottomSheet(),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ContentBottomSheet(
        title: '隐私政策',
        content: [
          '生效日期：2026年3月4日',
          '轻氧天气（以下简称“我们”）非常重视您的隐私。本协议阐述了我们如何处理您的个人信息。',
          ('1. 信息收集', '我们仅在您使用应用期间收集必要的信息，包括：\n• 位置信息：仅用于获取您当前位置的天气预报。您可以随时在系统中关闭该权限。'),
          ('2. 信息使用', '收集的信息仅用于向您提供准确的天气预报和相关推送服务。我们不会将您的个人信息出售给第三方。'),
          ('3. 数据存储', '您的位置偏好设置存储在设备本地（SharedPreferences），除非您手动清理应用数据，否则信息将保留在您的设备上。'),
          ('4. 第三方服务', '本应用使用和风天气（QWeather）及彩云天气提供的天气接口，您的位置坐标（经纬度）将发送至其服务器以换取天气数据。'),
        ],
      ),
    );
  }

  void _showUserAgreement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ContentBottomSheet(
        title: '用户协议',
        content: [
          '欢迎使用轻氧天气！请在使用前阅读以下条款。',
          ('1. 服务内容', '轻氧天气为您提供天气查询、极端天气预警及定时播报等非商业服务。'),
          ('2. 使用规范', '您不得将本应用用于任何非法目的，或以任何方式干扰应用的正常运行。'),
          ('3. 免责声明', '天气数据由第三方提供，受气象、地理、网络等多种因素影响，数据的准时性、准确性可能存在偏差。本应用不承担因天气数据错误导致的任何直接或间接损失。'),
          ('4. 协议变更', '我们保留随时修改本协议的权利，修改后的协议将在应用内公布。'),
        ],
      ),
    );
  }

}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _SettingsCard(child: Column(children: children)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.02);
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final Color color;

  const _ColorPreview({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _SelectionItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
}

class _SelectionBottomSheet extends StatelessWidget {
  final String title;
  final Iterable<_SelectionItem> items;
  final VoidCallback onClose;

  const _SelectionBottomSheet({
    required this.title,
    required this.items,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items.elementAt(index);
                    return _SelectionTile(item: item).animate().fadeIn(
                      delay: Duration(milliseconds: index * 50),
                      duration: 200.ms,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final _SelectionItem item;

  const _SelectionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: item.isSelected
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: item.isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              item.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: item.isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: item.isSelected
                                ? colorScheme.onSecondaryContainer
                                    .withValues(alpha: 0.7)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.onSecondaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentBottomSheet extends StatelessWidget {
  final String title;
  final List<dynamic> content;

  const _ContentBottomSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildBottomSheetHandle(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: content.length,
                  itemBuilder: (context, index) {
                    final item = content[index];
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      );
                    } else if (item is (String, String)) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.$2,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('我知道了'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
class _AboutBottomSheet extends StatelessWidget {
  const _AboutBottomSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildBottomSheetHandle(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const AppIcon(size: 80),
                      const SizedBox(height: 16),
                      Text(
                        '轻氧天气',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '版本 3.0.0',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      _buildAboutItem(
                        context,
                        Icons.info_outline,
                        '应用简介',
                        '一款简洁美观的天气应用，采用 Material You 设计语言，致力于提供极致的视觉体验。',
                      ),
                      _buildAboutItem(
                        context,
                        Icons.source_outlined,
                        '数据来源',
                        '和风天气、彩云天气',
                      ),
                      _buildAboutItem(
                        context,
                        Icons.code_outlined,
                        '开源地址',
                        'https://github.com/EchoRan6319/PureWeather',
                        isLink: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('关闭'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    IconData icon,
    String title,
    String content, {
    bool isLink = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                if (isLink)
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse(content),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  )
                else
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
