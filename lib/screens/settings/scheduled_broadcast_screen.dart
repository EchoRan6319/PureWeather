import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/scheduled_broadcast_provider.dart';
import '../../services/scheduled_broadcast_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/settings/settings.dart';
import '../../core/theme/app_theme.dart';

class ScheduledBroadcastScreen extends ConsumerWidget {
  const ScheduledBroadcastScreen({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(scheduledBroadcastProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '定时播报',
        children: [
          _buildDescriptionCard(context),
          const SizedBox(height: 8),
          _buildBasicSettings(context, ref, settings),
          _buildTimeSettings(context, ref, settings),
          _buildContentSettings(context, ref, settings),
          _buildTestSettings(context, ref, settings),
        ],
      ),
    );
  }

  static Widget _buildDescriptionCard(BuildContext context) {
    final cardBorderSide = BorderSide(
      color: context.uiTokens.cardBorder,
      width: 1,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(cardBorderSide),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '设置每日定时推送天气信息。Android 16+ 将优先尝试实时更新通知，不满足条件时自动回退普通通知。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBasicSettings(
    BuildContext context,
    WidgetRef ref,
    ScheduledBroadcastSettings settings,
  ) {
    return SettingsSection(
      title: '基本设置',
      icon: Icons.settings_outlined,
      showDividers: false,
      children: [
        SettingsSwitchTile(
          icon: Icons.notifications_active_outlined,
          title: '启用定时播报',
          subtitle: '开启后将在设定时间推送天气信息（优先实时更新）',
          value: settings.enabled,
          onChanged: (value) async {
            if (value) {
              final hasPermission = await _checkAndRequestPermissions(context);
              if (!hasPermission) return;
            }
            await ref
                .read(scheduledBroadcastProvider.notifier)
                .setEnabled(value);
            if (value) {
              await scheduledBroadcastServiceProvider.scheduleBroadcasts(
                settings,
              );
            } else {
              await scheduledBroadcastServiceProvider
                  .cancelAllScheduledBroadcasts();
            }
          },
        ),
      ],
    );
  }

  static Widget _buildTimeSettings(
    BuildContext context,
    WidgetRef ref,
    ScheduledBroadcastSettings settings,
  ) {
    return SettingsSection(
      title: '播报时间',
      icon: Icons.schedule_outlined,
      children: [
        _buildTimeTile(
          context,
          ref,
          title: '早间播报',
          subtitle: '推送今日天气情况',
          time: settings.morningTime,
          icon: Icons.wb_sunny_outlined,
          enabled: settings.enabled,
          onTimeChanged: (time) async {
            await ref
                .read(scheduledBroadcastProvider.notifier)
                .setMorningTime(time);
            if (settings.enabled) {
              await scheduledBroadcastServiceProvider.scheduleBroadcasts(
                settings.copyWith(morningTime: time),
              );
            }
          },
          onEnabledChanged: (enabled) async {
            final newTime = settings.morningTime.copyWith(enabled: enabled);
            await ref
                .read(scheduledBroadcastProvider.notifier)
                .setMorningTime(newTime);
            if (settings.enabled) {
              await scheduledBroadcastServiceProvider.scheduleBroadcasts(
                settings.copyWith(morningTime: newTime),
              );
            }
          },
        ),
        _buildTimeTile(
          context,
          ref,
          title: '晚间播报',
          subtitle: '推送次日天气情况',
          time: settings.eveningTime,
          icon: Icons.nightlight_outlined,
          enabled: settings.enabled,
          onTimeChanged: (time) async {
            await ref
                .read(scheduledBroadcastProvider.notifier)
                .setEveningTime(time);
            if (settings.enabled) {
              await scheduledBroadcastServiceProvider.scheduleBroadcasts(
                settings.copyWith(eveningTime: time),
              );
            }
          },
          onEnabledChanged: (enabled) async {
            final newTime = settings.eveningTime.copyWith(enabled: enabled);
            await ref
                .read(scheduledBroadcastProvider.notifier)
                .setEveningTime(newTime);
            if (settings.enabled) {
              await scheduledBroadcastServiceProvider.scheduleBroadcasts(
                settings.copyWith(eveningTime: newTime),
              );
            }
          },
        ),
      ],
    );
  }

  static Widget _buildContentSettings(
    BuildContext context,
    WidgetRef ref,
    ScheduledBroadcastSettings settings,
  ) {
    return SettingsSection(
      title: '播报内容',
      icon: Icons.article_outlined,
      children: [
        SettingsSwitchTile(
          icon: Icons.air_outlined,
          title: '包含风力风向',
          subtitle: '在播报中显示风向和风力等级',
          value: settings.includeWindInfo,
          onChanged: settings.enabled
              ? (value) async {
                  await ref
                      .read(scheduledBroadcastProvider.notifier)
                      .setIncludeWindInfo(value);
                }
              : null,
        ),
        SettingsSwitchTile(
          icon: Icons.water_drop_outlined,
          title: '包含湿度信息',
          subtitle: '在播报中显示空气湿度',
          value: settings.includeAirQuality,
          onChanged: settings.enabled
              ? (value) async {
                  await ref
                      .read(scheduledBroadcastProvider.notifier)
                      .setIncludeAirQuality(value);
                }
              : null,
        ),
      ],
    );
  }

  static Widget _buildTestSettings(
    BuildContext context,
    WidgetRef ref,
    ScheduledBroadcastSettings settings,
  ) {
    return SettingsSection(
      title: '测试',
      icon: Icons.play_circle_outline,
      children: [
        SettingsListTile(
          icon: Icons.wb_sunny_outlined,
          title: '测试早间播报',
          subtitle: '立即发送一条早间播报通知',
          onTap: () async {
            await _testBroadcast(context, ref, true, settings);
          },
        ),
        SettingsListTile(
          icon: Icons.nightlight_outlined,
          title: '测试晚间播报',
          subtitle: '立即发送一条晚间播报通知',
          onTap: () async {
            await _testBroadcast(context, ref, false, settings);
          },
        ),
      ],
    );
  }

  static Widget _buildTimeTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required ScheduledTime time,
    required IconData icon,
    required bool enabled,
    required Function(ScheduledTime) onTimeChanged,
    required Function(bool) onEnabledChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final iconColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    final titleColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && time.enabled
            ? () => _showTimePickerDialog(context, time, onTimeChanged)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time.formattedTime,
                style: textTheme.titleMedium?.copyWith(
                  color: enabled && time.enabled
                      ? colorScheme.primary
                      : colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: time.enabled,
                onChanged: enabled ? onEnabledChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool> _checkAndRequestPermissions(BuildContext context) async {
    final notificationGranted = await notificationServiceProvider
        .requestNotificationPermission();
    if (!notificationGranted) {
      if (context.mounted) {
        _showPermissionDeniedDialog(context, '通知权限', '定时播报需要通知权限才能推送天气信息');
      }
      return false;
    }

    final locationPermission = await Permission.location.status;
    if (!locationPermission.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        if (context.mounted) {
          _showPermissionDeniedDialog(
            context,
            '定位权限',
            '定时播报需要定位权限才能获取当前位置的天气信息',
          );
        }
        return false;
      }
    }

    if (context.mounted) {
      final shouldCheckAlarm = await _showScheduleExactAlarmDialog(context);
      if (shouldCheckAlarm == true) {
        await openAppSettings();
        return false;
      }

      // 检查电池优化
      if (defaultTargetPlatform == TargetPlatform.android) {
        final batteryStatus =
            await Permission.ignoreBatteryOptimizations.status;
        if (!batteryStatus.isGranted) {
          if (context.mounted) {
            final shouldRequest = await _showBatteryOptimizationDialog(context);
            if (shouldRequest == true) {
              await Permission.ignoreBatteryOptimizations.request();
            }
          }
        }
      }
    }

    return true;
  }

  static Future<bool?> _showBatteryOptimizationDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '改善后台稳定性',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('以后再说'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('去设置'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.battery_saver_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Android 系统可能会为了省电而延迟后台通知。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '建议将应用设为"不限制"电池使用，以确保天气播报准时送达。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  static Future<bool?> _showScheduleExactAlarmDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '重要提示',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('已开启'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('去检查'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.alarm,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '定时播报需要"闹钟和提醒"权限才能准时推送。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '请确保以下设置已开启：',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 设置 → 应用 → 轻氧天气 → 权限 → 闹钟和提醒',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '点击"去检查"跳转到设置页面确认。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  static void _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '需要$title',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('去设置'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '$message。请在系统设置中授予权限。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showTimePickerDialog(
    BuildContext context,
    ScheduledTime currentTime,
    Function(ScheduledTime) onTimeChanged,
  ) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    );
    if (selectedTime != null) {
      onTimeChanged(
        ScheduledTime(
          hour: selectedTime.hour,
          minute: selectedTime.minute,
          enabled: currentTime.enabled,
        ),
      );
    }
  }

  static Future<void> _testBroadcast(
    BuildContext context,
    WidgetRef ref,
    bool isMorning,
    ScheduledBroadcastSettings settings,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => SettingsBottomSheet(
        title: '请稍候',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '正在获取天气信息...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    try {
      if (isMorning) {
        await scheduledBroadcastServiceProvider.sendMorningBroadcast(settings);
      } else {
        await scheduledBroadcastServiceProvider.sendEveningBroadcast(settings);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('测试播报已发送'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
