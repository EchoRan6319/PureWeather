import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'dart:ui';
import '../../app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../services/live_update_diagnostics_service.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/settings/settings.dart';
import '../../core/constants/app_constants.dart';
import 'scheduled_broadcast_screen.dart';
import 'card_order_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;

        final scaffoldBody = ScrollConfiguration(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          // 个性化设置组
                          SettingsSection(
                            title: '个性化',
                            icon: Icons.palette_outlined,
                            animationDelay: 0,
                            children: [
                              SettingsListTile(
                                icon: Icons.brightness_6_outlined,
                                title: '主题模式',
                                subtitle: _getThemeModeName(
                                  themeSettings.themeMode,
                                ),
                                onTap: () => _showThemeModeDialog(
                                  context,
                                  ref,
                                  themeSettings,
                                ),
                              ),
                              // A屏黑主题开关（仅在深色模式下显示）
                              if (themeSettings.themeMode != AppThemeMode.light)
                                SettingsSwitchTile(
                                  icon: Icons.brightness_2_outlined,
                                  title: 'A屏黑主题',
                                  subtitle: '纯黑背景，更适合AMOLED屏幕',
                                  value: themeSettings.useAmoledBlack,
                                  onChanged: (value) {
                                    ref
                                        .read(themeProvider.notifier)
                                        .setUseAmoledBlack(value);
                                  },
                                ),
                              SettingsListTile(
                                icon: Icons.color_lens_outlined,
                                title: '主题颜色',
                                subtitle: themeSettings.useDynamicColor
                                    ? '跟随壁纸'
                                    : '自定义颜色',
                                onTap: () => _showColorPickerDialog(
                                  context,
                                  ref,
                                  themeSettings,
                                ),
                              ),
                              SettingsSwitchTile(
                                icon: Icons.wallpaper_outlined,
                                title: '动态取色',
                                subtitle: '根据壁纸自动生成主题色',
                                value: themeSettings.useDynamicColor,
                                onChanged: (value) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .setUseDynamicColor(value);
                                },
                              ),
                            ],
                          ),
                          // 通知设置组
                          SettingsSection(
                            title: '通知',
                            icon: Icons.notifications_outlined,
                            animationDelay: 50,
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.warning_amber_outlined,
                                title: '天气预警通知',
                                subtitle: '接收极端天气预警推送',
                                value: appSettings.notificationsEnabled,
                                onChanged: (value) async {
                                  if (value) {
                                    final hasPermission =
                                        await notificationServiceProvider
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
                              if (!kIsWeb &&
                                  defaultTargetPlatform ==
                                      TargetPlatform.android)
                                SettingsSwitchTile(
                                  icon: Icons.update_rounded,
                                  title: '实时更新通知',
                                  subtitle: 'Android 16+ 在通知栏持续显示当前天气',
                                  value: appSettings
                                      .androidLiveUpdateNotificationEnabled,
                                  onChanged: (value) async {
                                    final msgPermissionDenied = context.tr('未授予通知权限');
                                    final msgUnsupported = context.tr(
                                      '当前系统不支持实时更新通知（需 Android 16+）',
                                    );
                                    final msgUnsupportedSnack = context.tr(
                                      '该功能仅支持 Android 16 及以上系统',
                                    );
                                    final msgPromotedDenied = context.tr(
                                      '系统未允许应用发布 Promoted 实时更新通知',
                                    );
                                    if (value) {
                                      final hasPermission =
                                          await notificationServiceProvider
                                              .requestNotificationPermission();
                                      if (!hasPermission) {
                                        liveUpdateDiagnosticsService.record(
                                          scene: 'settings_toggle',
                                          success: false,
                                          code:
                                              'NOTIFICATION_PERMISSION_DENIED',
                                          message: msgPermissionDenied,
                                          settingEnabled: true,
                                          isAndroid: true,
                                          notificationPermission: false,
                                        );
                                        if (context.mounted) {
                                          _showPermissionDeniedDialog(context);
                                        }
                                        return;
                                      }

                                      final isSupported =
                                          await notificationServiceProvider
                                              .isAndroidLiveUpdateSupported();
                                      if (!isSupported) {
                                        liveUpdateDiagnosticsService.record(
                                          scene: 'settings_toggle',
                                          success: false,
                                          code: 'ANDROID_VERSION_UNSUPPORTED',
                                          message: msgUnsupported,
                                          settingEnabled: true,
                                          isAndroid: true,
                                          isSupported: false,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                msgUnsupportedSnack,
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      final canPostPromoted =
                                          await notificationServiceProvider
                                              .canPostPromotedNotifications();
                                      if (!canPostPromoted) {
                                        liveUpdateDiagnosticsService.record(
                                          scene: 'settings_toggle',
                                          success: false,
                                          code: 'PROMOTED_PERMISSION_DENIED',
                                          message: msgPromotedDenied,
                                          settingEnabled: true,
                                          isAndroid: true,
                                          isSupported: true,
                                          promotedPermission: false,
                                        );
                                        if (context.mounted) {
                                          _showPromotedNotificationDisabledDialog(
                                            context,
                                          );
                                        }
                                        return;
                                      }
                                    }

                                    await ref
                                        .read(settingsProvider.notifier)
                                        .setAndroidLiveUpdateNotificationEnabled(
                                          value,
                                        );
                                    await ref
                                        .read(weatherProvider.notifier)
                                        .syncAndroidLiveUpdateNotificationWithSettings(
                                          scene: value
                                              ? 'settings_toggle_on'
                                              : 'settings_toggle_off',
                                        );
                                  },
                                ),
                              SettingsListTile(
                                icon: Icons.schedule_outlined,
                                title: '定时播报',
                                subtitle: '设置每日定时推送天气信息',
                                onTap: () =>
                                    ScheduledBroadcastScreen.show(context, ref),
                              ),
                              if (kDebugMode &&
                                  !kIsWeb &&
                                  defaultTargetPlatform ==
                                      TargetPlatform.android)
                                SettingsListTile(
                                  icon: Icons.bug_report_outlined,
                                  title: '实时更新诊断面板',
                                  subtitle: '仅 Debug 版本可见，查看失败卡点',
                                  onTap: () =>
                                      _showLiveUpdateDiagnosticsPanel(context),
                                ),
                            ],
                          ),
                          // 显示设置组
                          SettingsSection(
                            title: '显示',
                            icon: Icons.visibility_outlined,
                            animationDelay: 100,
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.psychology_outlined,
                                title: '显示天气助手',
                                subtitle: '在底部导航栏显示天气助手页面',
                                value: appSettings.showAIAssistant,
                                onChanged: (value) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setShowAIAssistant(value);
                                },
                              ),
                              SettingsListTile(
                                icon: Icons.language_outlined,
                                title: '语言',
                                subtitle: _getAppLanguageName(
                                  appSettings.appLanguage,
                                ),
                                onTap: () => _showAppLanguageDialog(
                                  context,
                                  ref,
                                  appSettings,
                                ),
                              ),
                              SettingsListTile(
                                icon: Icons.device_thermostat_outlined,
                                title: '温度单位',
                                subtitle:
                                    appSettings.temperatureUnit == 'celsius'
                                    ? '${context.tr('摄氏度')} (°C)'
                                    : '${context.tr('华氏度')} (°F)',
                                onTap: () => _showTemperatureUnitDialog(
                                  context,
                                  ref,
                                  appSettings,
                                ),
                              ),
                              SettingsListTile(
                                icon: Icons.location_on_outlined,
                                title: '位置显示精度',
                                subtitle:
                                    appSettings.locationAccuracyLevel ==
                                        LocationAccuracyLevel.street
                                    ? '街道级别'
                                    : '区县级别',
                                onTap: () => _showLocationAccuracyDialog(
                                  context,
                                  ref,
                                  appSettings,
                                ),
                              ),
                              SettingsListTile(
                                icon: Icons.sort_rounded,
                                title: '天气卡片排序',
                                subtitle: '自定义天气详情页卡片显示顺序',
                                onTap: () => CardOrderScreen.show(context),
                              ),
                            ],
                          ),
                          // 数据设置组
                          SettingsSection(
                            title: '数据',
                            icon: Icons.sync_outlined,
                            animationDelay: 150,
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.autorenew_outlined,
                                title: '自动刷新',
                                subtitle: context.tr(
                                  '每 {minutes} 分钟自动更新',
                                  args: {
                                    'minutes': appSettings.refreshInterval,
                                  },
                                ),
                                value: appSettings.autoRefreshEnabled,
                                onChanged: (value) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setAutoRefreshEnabled(value);
                                },
                              ),
                              SettingsListTile(
                                icon: Icons.timer_outlined,
                                title: '刷新间隔',
                                subtitle: context.tr(
                                  '{minutes} 分钟',
                                  args: {
                                    'minutes': appSettings.refreshInterval,
                                  },
                                ),
                                onTap: () => _showRefreshIntervalDialog(
                                  context,
                                  ref,
                                  appSettings,
                                ),
                              ),
                            ],
                          ),
                          // 高级设置组
                          SettingsSection(
                            title: '高级',
                            icon: Icons.tune_outlined,
                            animationDelay: 200,
                            children: [
                              SettingsSwitchTile(
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
                          // 关于设置组
                          SettingsSection(
                            title: '关于',
                            icon: Icons.info_outline,
                            animationDelay: 250,
                            children: [
                              SettingsListTile(
                                icon: Icons.apps_outlined,
                                title: '关于轻氧天气',
                                onTap: () => _showAboutDialog(context),
                              ),
                              SettingsListTile(
                                icon: Icons.privacy_tip_outlined,
                                title: '隐私政策',
                                onTap: () => _showPrivacyPolicy(context),
                              ),
                              SettingsListTile(
                                icon: Icons.description_outlined,
                                title: '用户协议',
                                onTap: () => _showUserAgreement(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        return Scaffold(
          appBar: AppBar(title: Text(context.tr('设置'))),
          body: scaffoldBody,
        );
      },
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

  String _getAppLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.system:
        return '默认跟随系统';
      case AppLanguage.zhCN:
        return '简体中文';
      case AppLanguage.enUS:
        return 'English (US)';
    }
  }

  void _showAppLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final options = [
      (AppLanguage.system, '默认跟随系统', '自动跟随系统语言', Icons.smartphone_outlined),
      (AppLanguage.zhCN, '简体中文', '始终使用简体中文', Icons.translate_outlined),
      (
        AppLanguage.enUS,
        'English (US)',
        'Always use English (US)',
        Icons.language_outlined,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '语言',
        children: options.map((option) {
          return SettingsSelectionItem(
            title: option.$2,
            subtitle: option.$3,
            icon: option.$4,
            isSelected: settings.appLanguage == option.$1,
            onTap: () async {
              await ref
                  .read(settingsProvider.notifier)
                  .setAppLanguage(option.$1);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    final themeModes = [
      (AppThemeMode.system, '跟随系统', '自动切换浅色或深色主题'),
      (AppThemeMode.light, '浅色模式', '使用浅色主题显示'),
      (AppThemeMode.dark, '深色模式', '使用深色主题显示'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '主题模式',
        children: themeModes.map((mode) {
          return SettingsSelectionItem(
            title: mode.$2,
            subtitle: mode.$3,
            icon: _getThemeModeIcon(mode.$1),
            isSelected: settings.themeMode == mode.$1,
            onTap: () {
              ref.read(themeProvider.notifier).setThemeMode(mode.$1);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
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
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => SettingsBottomSheet(
          title: '选择主题颜色',
          bottomAction: _buildActionButtons(
            context,
            ref,
            ctx,
            selectedColor,
            settings,
          ),
          children: [
            _buildDynamicColorSection(context, ref, settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '预设颜色'),
            const SizedBox(height: 12),
            _buildPresetColors(context, settings, selectedColor, (color) {
              setState(() {
                selectedColor = color;
                hexController.text =
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              });
            }),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '自定义颜色'),
            const SizedBox(height: 12),
            _buildCustomColorPicker(context, selectedColor, hexController, (
              color,
            ) {
              setState(() {
                selectedColor = color;
                hexController.text =
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              });
            }),
            const SizedBox(height: 24),
            _buildHexInputSection(context, hexController, (color) {
              setState(() {
                selectedColor = color;
              });
            }),
            const SizedBox(height: 24),
            _buildSelectedColorPreview(context, selectedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      context.tr(title),
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
    final tokens = context.uiTokens;
    return FutureBuilder<Color?>(
      future: _getWallpaperColor(),
      builder: (context, snapshot) {
        final wallpaperColor = snapshot.data;
        final isCurrentDynamic = settings.useDynamicColor;

        if (wallpaperColor == null) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final isSupported = lightDynamic != null;
              final dynamicColor = lightDynamic?.primary;

              if (!isSupported) {
                return _buildDynamicColorNotSupported(context);
              }

              return Material(
                color: isCurrentDynamic
                    ? tokens.selectedBackground
                    : tokens.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: tokens.cardBorder, width: 1),
                ),
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
                            border: null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('壁纸取色'),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isCurrentDynamic
                                          ? tokens.selectedForeground
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr(
                                  '检测颜色: #{color}',
                                  args: {
                                    'color': dynamicColor!
                                        .toARGB32()
                                        .toRadixString(16)
                                        .substring(2)
                                        .toUpperCase(),
                                  },
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isCurrentDynamic
                                          ? tokens.selectedForeground
                                                .withValues(alpha: 0.7)
                                          : Theme.of(
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
                            color: tokens.selectedForeground,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Material(
          color: isCurrentDynamic
              ? tokens.selectedBackground
              : tokens.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tokens.cardBorder, width: 1),
          ),
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
                      color: wallpaperColor,
                      borderRadius: BorderRadius.circular(12),
                      border: null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('壁纸取色'),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isCurrentDynamic
                                    ? tokens.selectedForeground
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            '检测颜色: #{color}',
                            args: {
                              'color': wallpaperColor
                                  .toARGB32()
                                  .toRadixString(16)
                                  .substring(2)
                                  .toUpperCase(),
                            },
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isCurrentDynamic
                                    ? tokens.selectedForeground.withValues(
                                        alpha: 0.7,
                                      )
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentDynamic)
                    Icon(Icons.check_circle, color: tokens.selectedForeground),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Color?> _getWallpaperColor() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    try {
      const channel = MethodChannel('com.echoran.pureweather/wallpaper');
      final int? colorInt = await channel.invokeMethod<int>(
        'getWallpaperPrimaryColor',
      );
      if (colorInt != null) {
        return Color(colorInt);
      }
    } catch (e) {
      debugPrint('[DynamicColor] Failed to get wallpaper color: $e');
    }
    return null;
  }

  Widget _buildDynamicColorNotSupported(BuildContext context) {
    final tokens = context.uiTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.dangerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.dangerBorder, width: 1),
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
                context.tr('动态取色不可用'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              '可能原因：\n• 设备系统版本低于 Android 12\n• 设备制造商禁用了动态取色\n• 系统设置中未启用 Material You',
            ),
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
    final tokens = context.uiTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
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
                    ? Border.all(color: tokens.selectedBorder, width: 2)
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
    );
  }

  Widget _buildCustomColorPicker(
    BuildContext context,
    Color selectedColor,
    TextEditingController hexController,
    Function(Color) onColorSelected,
  ) {
    final tokens = context.uiTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: ColorPicker(
        pickerColor: selectedColor,
        onColorChanged: onColorSelected,
        pickerAreaHeightPercent: 0.6,
        enableAlpha: false,
        labelTypes: const [],
        portraitOnly: true,
        pickerAreaBorderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildHexInputSection(
    BuildContext context,
    TextEditingController hexController,
    Function(Color) onColorParsed,
  ) {
    final tokens = context.uiTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('十六进制颜色代码'),
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
    final tokens = context.uiTokens;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('预览效果'),
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
                    context.tr('主色'),
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
                    context.tr('次色'),
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
                    context.tr('三色'),
                    style: TextStyle(color: colorScheme.onTertiary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.tr('重置')),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.tr('应用')),
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
    final intervals = [
      (15, '每15分钟自动更新天气数据'),
      (30, '每30分钟自动更新天气数据'),
      (60, '每小时自动更新天气数据'),
      (120, '每2小时自动更新天气数据'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '刷新间隔',
        children: intervals.map((interval) {
          return SettingsSelectionItem(
            title: context.tr('{minutes} 分钟', args: {'minutes': interval.$1}),
            subtitle: interval.$2,
            icon: Icons.timer_outlined,
            isSelected: settings.refreshInterval == interval.$1,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setRefreshInterval(interval.$1);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
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
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '温度单位',
        children: units.map((unit) {
          return SettingsSelectionItem(
            title: '${context.tr(unit.$2)} (${unit.$3})',
            subtitle: unit.$4,
            icon: unit.$5,
            isSelected: settings.temperatureUnit == unit.$1,
            onTap: () {
              ref.read(settingsProvider.notifier).setTemperatureUnit(unit.$1);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
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
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '位置显示精度',
        children: options.map((option) {
          return SettingsSelectionItem(
            title: option.$2,
            subtitle: option.$3,
            icon: option.$4,
            isSelected: settings.locationAccuracyLevel == option.$1,
            onTap: () async {
              await ref
                  .read(settingsProvider.notifier)
                  .setLocationAccuracyLevel(option.$1);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '需要通知权限',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('取消')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: Text(context.tr('去设置')),
              ),
            ),
          ],
        ),
        children: [
          _BottomSheetTokenCard(
            variant: _BottomSheetTokenCardVariant.danger,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('轻氧天气需要通知权限才能推送天气预警。请在系统设置中授予通知权限。'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotedNotificationDisabledDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '需要开启实时更新权限',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('取消')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final opened = await notificationServiceProvider
                      .openPromotedNotificationSettings();
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('无法打开系统实时更新设置页'))),
                    );
                  }
                },
                child: Text(context.tr('去开启')),
              ),
            ),
          ],
        ),
        children: [
          _BottomSheetTokenCard(
            variant: _BottomSheetTokenCardVariant.danger,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.update_disabled_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr(
                      '系统当前未允许应用发布实时更新（Promoted）通知。请先在系统页面开启，再返回打开本开关。',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveUpdateDiagnosticsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '实时更新诊断（Debug）',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('关闭')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  liveUpdateDiagnosticsService.clear();
                },
                child: Text(context.tr('清空记录')),
              ),
            ),
          ],
        ),
        children: [
          _BottomSheetTokenCard(
            child: Text(
              context.tr('每次尝试会记录：系统支持、通知权限、Promoted 权限、可推广特征等检查结果。'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ValueListenableBuilder<List<LiveUpdateDiagnosticEntry>>(
            valueListenable: liveUpdateDiagnosticsService.entries,
            builder: (context, entries, _) {
              if (entries.isEmpty) {
                return _BottomSheetTokenCard(
                  child: Text(
                    context.tr('暂无诊断记录。触发一次实时更新后再回来查看。'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                children: entries.map((entry) {
                  final statusColor = entry.success
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error;

                  return _BottomSheetTokenCard(
                    variant: entry.success
                        ? _BottomSheetTokenCardVariant.normal
                        : _BottomSheetTokenCardVariant.danger,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entry.success
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              size: 18,
                              color: statusColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '[${entry.scene}] ${entry.code}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Text(
                              _formatDiagnosticTime(entry.timestamp),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (entry.titlePreview != null &&
                            entry.titlePreview!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            context.tr(
                              '标题预览：{title}',
                              args: {'title': entry.titlePreview},
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildDiagnosticFlag(
                              context,
                              context.tr('开关'),
                              entry.settingEnabled,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              'Android',
                              entry.isAndroid,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              context.tr('有天气数据'),
                              entry.hasWeatherData,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              context.tr('系统支持'),
                              entry.isSupported,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              context.tr('通知权限'),
                              entry.notificationPermission,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              context.tr('Promoted权限'),
                              entry.promotedPermission,
                            ),
                            _buildDiagnosticFlag(
                              context,
                              context.tr('可推广特征'),
                              entry.promotableCharacteristics,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticFlag(BuildContext context, String label, bool? value) {
    final colorScheme = Theme.of(context).colorScheme;
    final (Color bgColor, Color textColor, String text) = switch (value) {
      true => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        '$label: ✓',
      ),
      false => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        '$label: ✗',
      ),
      null => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        '$label: -',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: textColor),
      ),
    );
  }

  String _formatDiagnosticTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AboutBottomSheet(),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ContentBottomSheet(
        title: '隐私政策',
        content: [
          '生效日期：2026年2月16日\n\n轻氧天气（以下简称"我们"）非常重视您的隐私。本协议阐述了我们如何处理您的个人信息。',
          (
            '1. 信息收集',
            '我们仅在您使用应用期间收集必要的信息，包括：\n• 位置信息：仅用于获取您当前位置的天气预报。您可以随时在系统中关闭该权限。\n• 天气查询历史：仅用于天气助手功能，帮助您获取更准确的天气相关回答。',
          ),
          ('2. 信息使用', '收集的信息仅用于向您提供准确的天气预报、相关推送服务和天气助手功能。我们不会将您的个人信息出售给第三方。'),
          (
            '3. 数据存储',
            '您的位置偏好设置和城市信息存储在设备本地（SharedPreferences），除非您手动清理应用数据，否则信息将保留在您的设备上。',
          ),
          (
            '4. 第三方服务',
            '本应用使用以下第三方服务：\n• 和风天气（QWeather）及彩云天气：提供天气数据，您的位置坐标（经纬度）将发送至其服务器以换取天气数据。\n• 高德地图：提供城市搜索和定位服务，您的位置坐标（经纬度）将发送至其服务器以获取位置信息。\n• DeepSeek：提供天气助手的AI问答功能，您的天气查询问题将发送至其服务器以获取智能回答。',
          ),
        ],
      ),
    );
  }

  void _showUserAgreement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ContentBottomSheet(
        title: '用户协议',
        content: [
          '欢迎使用轻氧天气！请在使用前阅读以下条款。',
          ('1. 服务内容', '轻氧天气为您提供天气查询、极端天气预警、定时播报、城市搜索定位及天气助手等非商业服务。'),
          (
            '2. 使用规范',
            '您不得将本应用用于任何非法目的，或以任何方式干扰应用的正常运行。在使用天气助手功能时，您应遵守相关法律法规，不得发送违法或不当内容。',
          ),
          (
            '3. 免责声明',
            '• 天气数据由第三方提供，受气象、地理、网络等多种因素影响，数据的准时性、准确性可能存在偏差。本应用不承担因天气数据错误导致的任何直接或间接损失。\n• 定位服务由高德地图提供，其准确性和可用性受设备硬件和网络环境影响。\n• 天气助手功能由DeepSeek提供，其回答基于AI模型，可能存在一定的局限性和误差，仅供参考。',
          ),
          (
            '4. 第三方服务',
            '本应用使用和风天气、彩云天气、高德地图和DeepSeek等第三方服务，您在使用本应用时即表示同意这些第三方服务的相关条款。',
          ),
          ('5. 协议变更', '我们保留随时修改本协议的权利，修改后的协议将在应用内公布。'),
        ],
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
    return SettingsBottomSheet(
      title: title,
      bottomAction: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(context.tr('我知道了')),
        ),
      ),
      children: content.map((item) {
        if (item is String) {
          return _BottomSheetTokenCard(
            child: Text(
              context.tr(item),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          );
        }
        if (item is (String, String)) {
          return _BottomSheetTokenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(item.$1),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(item.$2),
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
      }).toList(),
    );
  }
}

class _AboutBottomSheet extends StatelessWidget {
  const _AboutBottomSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsBottomSheet(
      title: '关于轻氧天气',
      bottomAction: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(context.tr('我知道了')),
        ),
      ),
      children: [
        _BottomSheetTokenCard(
          child: Center(
            child: Column(
              children: [
                const AppIcon(size: 80),
                const SizedBox(height: 16),
                Text(
                  context.tr('轻氧天气'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    '版本 {version}',
                    args: {'version': AppConstants.appVersion},
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomSheetTokenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAboutItem(
                context,
                Icons.info_outline,
                '应用介绍',
                '轻氧天气是一款使用 Material You Design 的现代化跨平台天气应用，支持全平台。',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                Icons.code_outlined,
                '开源协议',
                'MIT License',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(context, Icons.people_outline, '开发者', 'EchoRan'),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                Icons.link_outlined,
                'GitHub',
                'https://github.com/EchoRan6319/PureWeather',
                isLink: true,
              ),
            ],
          ),
        ),
        _BottomSheetTokenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('特别鸣谢'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAboutItem(context, Icons.cloud_outlined, '和风天气', '提供天气数据'),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                Icons.cloud_queue_outlined,
                '彩云天气',
                '提供分钟级降雨预报',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                Icons.location_on_outlined,
                '高德地图',
                '提供城市搜索和定位服务',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                Icons.lightbulb_outlined,
                'DeepSeek',
                '提供天气助手的 AI 问答功能',
              ),
            ],
          ),
        ),
      ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(title),
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
                  context.tr(content),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _BottomSheetTokenCardVariant { normal, danger }

class _BottomSheetTokenCard extends StatelessWidget {
  final Widget child;
  final _BottomSheetTokenCardVariant variant;
  const _BottomSheetTokenCard({
    required this.child,
    this.variant = _BottomSheetTokenCardVariant.normal,
  });
  @override
  Widget build(BuildContext context) {
    final tokens = context.uiTokens;
    final isDanger = variant == _BottomSheetTokenCardVariant.danger;
    final background = isDanger
        ? tokens.dangerBackground
        : tokens.cardBackground;
    final border = isDanger ? tokens.dangerBorder : tokens.cardBorder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: child,
      ),
    );
  }
}
