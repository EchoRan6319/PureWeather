import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
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
                            icon: LucideIcons.palette,
                            animationDelay: 0,
                            children: [
                              SettingsListTile(
                                icon: LucideIcons.sunMoon,
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
                            ],
                          ),
                          // 通知设置组
                          SettingsSection(
                            title: '通知',
                            icon: LucideIcons.bell,
                            animationDelay: 50,
                            children: [
                              SettingsSwitchTile(
                                icon: LucideIcons.alertTriangle,
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
                                  icon: LucideIcons.refreshCw,
                                  title: '实时更新通知',
                                  subtitle: 'Android 16+ 在通知栏持续显示当前天气',
                                  value: appSettings
                                      .androidLiveUpdateNotificationEnabled,
                                  onChanged: (value) async {
                                    final msgPermissionDenied = context.tr(
                                      '未授予通知权限',
                                    );
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
                                icon: LucideIcons.clock,
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
                                  icon: LucideIcons.bug,
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
                            icon: LucideIcons.eye,
                            animationDelay: 100,
                            children: [
                              SettingsListTile(
                                icon: LucideIcons.globe,
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
                                icon: LucideIcons.thermometer,
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
                                icon: LucideIcons.mapPin,
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
                                icon: LucideIcons.arrowUpDown,
                                title: '天气卡片排序',
                                subtitle: '自定义天气详情页卡片显示顺序',
                                onTap: () => CardOrderScreen.show(context),
                              ),
                            ],
                          ),
                          // AI 设置组
                          SettingsSection(
                            title: 'AI 设置',
                            icon: LucideIcons.brain,
                            animationDelay: 150,
                            children: [
                              SettingsSwitchTile(
                                icon: LucideIcons.bot,
                                title: '启用天气助手',
                                subtitle: '默认关闭，开启后在底部导航栏显示天气助手',
                                value: appSettings.showAIAssistant,
                                onChanged: (value) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setShowAIAssistant(value);
                                },
                              ),
                              SettingsListTile(
                                icon: LucideIcons.keyRound,
                                title: '模型与接口',
                                subtitle: _getAiSettingsSummary(appSettings),
                                onTap: () => _showAiSettingsSheet(context),
                              ),
                            ],
                          ),
                          // 数据设置组
                          SettingsSection(
                            title: '数据',
                            icon: LucideIcons.refreshCw,
                            animationDelay: 200,
                            children: [
                              SettingsSwitchTile(
                                icon: LucideIcons.rotateCw,
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
                                icon: LucideIcons.timer,
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
                            icon: LucideIcons.slidersHorizontal,
                            animationDelay: 250,
                            children: [
                              SettingsSwitchTile(
                                icon: LucideIcons.hand,
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
                            icon: LucideIcons.info,
                            animationDelay: 300,
                            children: [
                              SettingsListTile(
                                icon: LucideIcons.layoutGrid,
                                title: '关于极光天气',
                                onTap: () => _showAboutDialog(context),
                              ),
                              SettingsListTile(
                                icon: LucideIcons.shield,
                                title: '隐私政策',
                                onTap: () => _showPrivacyPolicy(context),
                              ),
                              SettingsListTile(
                                icon: LucideIcons.fileText,
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
        return LucideIcons.monitor;
      case AppThemeMode.light:
        return LucideIcons.sun;
      case AppThemeMode.dark:
        return LucideIcons.moon;
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

  String _getAiProviderName(AiProviderType providerType) {
    switch (providerType) {
      case AiProviderType.anthropic:
        return 'Anthropic';
      case AiProviderType.openAiCompatible:
        return 'OpenAI 兼容';
    }
  }

  String _getAiSettingsSummary(AppSettings settings) {
    final hasApiKey = settings.aiApiKey.trim().isNotEmpty;
    final hasModel = settings.aiModel.trim().isNotEmpty;
    if (!hasApiKey || !hasModel) {
      return '未配置 API Key 或模型';
    }
    return '${_getAiProviderName(settings.aiProviderType)} · ${settings.aiModel}';
  }

  void _showAiSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AiSettingsBottomSheet(),
    );
  }

  void _showAppLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final options = [
      (AppLanguage.system, '默认跟随系统', '自动跟随系统语言', LucideIcons.smartphone),
      (AppLanguage.zhCN, '简体中文', '始终使用简体中文', LucideIcons.languages),
      (
        AppLanguage.enUS,
        'English (US)',
        'Always use English (US)',
        LucideIcons.globe,
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
            icon: LucideIcons.timer,
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
      ('celsius', '摄氏度', '°C', '温度显示为摄氏度', LucideIcons.thermometer),
      ('fahrenheit', '华氏度', '°F', '温度显示为华氏度', LucideIcons.thermometer),
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
        LucideIcons.building2,
      ),
      (
        LocationAccuracyLevel.street,
        '展示附近地标/街道',
        '精确定位到街道级别',
        LucideIcons.mapPin,
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
                  LucideIcons.bellOff,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('极光天气需要通知权限才能推送天气预警。请在系统设置中授予通知权限。'),
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
                  LucideIcons.refreshCwOff,
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
                                  ? LucideIcons.checkCircle
                                  : LucideIcons.alertCircle,
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
          '生效日期：2026年2月16日\n\n极光天气（以下简称"我们"）非常重视您的隐私。本协议阐述了我们如何处理您的个人信息。',
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
            '本应用使用以下第三方服务：\n• 和风天气（QWeather）及彩云天气：提供天气数据，您的位置坐标（经纬度）将发送至其服务器以换取天气数据。\n• 高德地图：提供城市搜索和定位服务，您的位置坐标（经纬度）将发送至其服务器以获取位置信息。\n• 用户配置的 AI 服务：仅在您开启并配置天气助手后，您的天气查询问题会发送至对应服务以获取智能回答。',
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
          '欢迎使用极光天气！请在使用前阅读以下条款。',
          ('1. 服务内容', '极光天气为您提供天气查询、极端天气预警、定时播报、城市搜索定位及天气助手等非商业服务。'),
          (
            '2. 使用规范',
            '您不得将本应用用于任何非法目的，或以任何方式干扰应用的正常运行。在使用天气助手功能时，您应遵守相关法律法规，不得发送违法或不当内容。',
          ),
          (
            '3. 免责声明',
            '• 天气数据由第三方提供，受气象、地理、网络等多种因素影响，数据的准时性、准确性可能存在偏差。本应用不承担因天气数据错误导致的任何直接或间接损失。\n• 定位服务由高德地图提供，其准确性和可用性受设备硬件和网络环境影响。\n• 天气助手回答由您配置的 AI 服务生成，可能存在一定的局限性和误差，仅供参考。',
          ),
          (
            '4. 第三方服务',
            '本应用使用和风天气、彩云天气、高德地图以及您自行配置的 AI 服务。您在使用相关功能时即表示同意这些第三方服务的相关条款。',
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

class _AiSettingsBottomSheet extends ConsumerStatefulWidget {
  const _AiSettingsBottomSheet();

  @override
  ConsumerState<_AiSettingsBottomSheet> createState() =>
      _AiSettingsBottomSheetState();
}

class _AiSettingsBottomSheetState
    extends ConsumerState<_AiSettingsBottomSheet> {
  late AiProviderType _providerType;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _providerType = settings.aiProviderType;
    _apiKeyController = TextEditingController(text: settings.aiApiKey);
    _baseUrlController = TextEditingController(text: settings.aiBaseUrl);
    _modelController = TextEditingController(text: settings.aiModel);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsBottomSheet(
      title: 'AI 设置',
      bottomAction: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('取消')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _save,
              child: Text(context.tr('保存')),
            ),
          ),
        ],
      ),
      children: [
        _BottomSheetTokenCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('天气助手默认关闭。API Key 仅保存在本机，用于请求你配置的 AI 服务。'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        SettingsSelectionItem(
          title: 'OpenAI 兼容',
          subtitle: '适用于 OpenAI、DeepSeek、通义千问等兼容 Chat Completions 的接口',
          icon: LucideIcons.workflow,
          isSelected: _providerType == AiProviderType.openAiCompatible,
          onTap: () => _setProviderType(AiProviderType.openAiCompatible),
        ),
        SettingsSelectionItem(
          title: 'Anthropic',
          subtitle: '适用于 Claude Messages API',
          icon: LucideIcons.sparkles,
          isSelected: _providerType == AiProviderType.anthropic,
          onTap: () => _setProviderType(AiProviderType.anthropic),
        ),
        _BottomSheetTokenCard(
          child: Column(
            children: [
              _buildTextField(
                controller: _apiKeyController,
                label: 'API Key',
                hintText: _providerType == AiProviderType.anthropic
                    ? 'sk-ant-...'
                    : 'sk-...',
                icon: LucideIcons.keyRound,
                obscureText: _obscureApiKey,
                trailing: IconButton(
                  icon: Icon(
                    _obscureApiKey ? LucideIcons.eye : LucideIcons.eyeOff,
                  ),
                  tooltip: context.tr(
                    _obscureApiKey ? '显示 API Key' : '隐藏 API Key',
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _baseUrlController,
                label: '接口地址',
                hintText: _providerType == AiProviderType.anthropic
                    ? 'https://api.anthropic.com/v1'
                    : 'https://api.openai.com/v1',
                icon: LucideIcons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _modelController,
                label: '模型名称',
                hintText: _providerType == AiProviderType.anthropic
                    ? 'claude-3-5-haiku-latest'
                    : 'gpt-4o-mini / deepseek-chat / qwen-plus',
                icon: LucideIcons.cpu,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setProviderType(AiProviderType value) {
    setState(() {
      _providerType = value;
      final currentBaseUrl = _baseUrlController.text.trim();
      if (currentBaseUrl.isEmpty ||
          currentBaseUrl == 'https://api.openai.com/v1' ||
          currentBaseUrl == 'https://api.anthropic.com/v1') {
        _baseUrlController.text = value == AiProviderType.anthropic
            ? 'https://api.anthropic.com/v1'
            : 'https://api.openai.com/v1';
      }
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setAiProviderType(_providerType);
    await notifier.setAiApiKey(_apiKeyController.text);
    await notifier.setAiBaseUrl(_baseUrlController.text);
    await notifier.setAiModel(_modelController.text);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: context.tr(label),
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.uiTokens.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.uiTokens.selectedBorder),
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

    return SettingsBottomSheet(
      title: '关于极光天气',
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
                  context.tr('极光天气'),
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
                LucideIcons.info,
                '应用介绍',
                '极光天气是一款使用 Aurora UI 的现代化跨平台天气应用，支持全平台。',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                LucideIcons.code2,
                '开源协议',
                'MIT License',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(context, LucideIcons.user, '开发者', 'EchoRan'),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                LucideIcons.link,
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
                    LucideIcons.heart,
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
              _buildAboutItem(context, LucideIcons.cloud, '和风天气', '提供天气数据'),
              const SizedBox(height: 16),
              _buildAboutItem(context, LucideIcons.cloud, '彩云天气', '提供分钟级降雨预报'),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                LucideIcons.mapPin,
                '高德地图',
                '提供城市搜索和定位服务',
              ),
              const SizedBox(height: 16),
              _buildAboutItem(
                context,
                LucideIcons.lightbulb,
                'AI 服务',
                '天气助手使用您自行配置的模型与接口',
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
                Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => launchUrl(
                      Uri.parse(content),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
