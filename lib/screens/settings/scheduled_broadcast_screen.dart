import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/scheduled_broadcast_provider.dart';
import '../../services/scheduled_broadcast_service.dart';

class ScheduledBroadcastScreen extends ConsumerWidget {
  const ScheduledBroadcastScreen({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            _ScheduledBroadcastSheet(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _ScheduledBroadcastSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _ScheduledBroadcastSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(scheduledBroadcastProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '定时播报',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDescriptionCard(context),
                _buildSection(
                  context,
                  title: '基本设置',
                  icon: Icons.settings_outlined,
                  children: [
                    _SettingsSwitch(
                      icon: Icons.notifications_active_outlined,
                      title: '启用定时播报',
                      subtitle: '开启后将在设定时间推送天气信息',
                      value: settings.enabled,
                      onChanged: (value) async {
                        if (value) {
                          final hasPermission =
                              await _checkAndRequestPermissions(context);
                          if (!hasPermission) return;
                        }
                        await ref
                            .read(scheduledBroadcastProvider.notifier)
                            .setEnabled(value);
                        if (value) {
                          await scheduledBroadcastServiceProvider
                              .scheduleBroadcasts(settings);
                        } else {
                          await scheduledBroadcastServiceProvider
                              .cancelAllScheduledBroadcasts();
                        }
                      },
                    ),
                  ],
                ),
                _buildSection(
                  context,
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
                          await scheduledBroadcastServiceProvider
                              .scheduleBroadcasts(
                                settings.copyWith(morningTime: time),
                              );
                        }
                      },
                      onEnabledChanged: (enabled) async {
                        final newTime = settings.morningTime.copyWith(
                          enabled: enabled,
                        );
                        await ref
                            .read(scheduledBroadcastProvider.notifier)
                            .setMorningTime(newTime);
                        if (settings.enabled) {
                          await scheduledBroadcastServiceProvider
                              .scheduleBroadcasts(
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
                          await scheduledBroadcastServiceProvider
                              .scheduleBroadcasts(
                                settings.copyWith(eveningTime: time),
                              );
                        }
                      },
                      onEnabledChanged: (enabled) async {
                        final newTime = settings.eveningTime.copyWith(
                          enabled: enabled,
                        );
                        await ref
                            .read(scheduledBroadcastProvider.notifier)
                            .setEveningTime(newTime);
                        if (settings.enabled) {
                          await scheduledBroadcastServiceProvider
                              .scheduleBroadcasts(
                                settings.copyWith(eveningTime: newTime),
                              );
                        }
                      },
                    ),
                  ],
                ),
                _buildSection(
                  context,
                  title: '播报内容',
                  icon: Icons.article_outlined,
                  children: [
                    _SettingsSwitch(
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
                    _SettingsSwitch(
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
                ),
                _buildSection(
                  context,
                  title: '测试',
                  icon: Icons.play_circle_outline,
                  children: [
                    _SettingsTile(
                      icon: Icons.wb_sunny_outlined,
                      title: '测试早间播报',
                      subtitle: '立即发送一条早间播报通知',
                      onTap: () async {
                        await _testBroadcast(context, ref, true, settings);
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.nightlight_outlined,
                      title: '测试晚间播报',
                      subtitle: '立即发送一条晚间播报通知',
                      onTap: () async {
                        await _testBroadcast(context, ref, false, settings);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
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
                '设置每日定时推送天气信息，仅支持当前定位所在地',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
    );
  }

  Widget _buildTimeTile(
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
              Icon(
                icon,
                size: 22,
                color: enabled
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                        color: enabled
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time.formattedTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: enabled && time.enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
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

  Future<bool> _checkAndRequestPermissions(BuildContext context) async {
    final notificationPermission = await Permission.notification.status;
    if (!notificationPermission.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context, '通知权限', '定时播报需要通知权限才能推送天气信息');
        }
        return false;
      }
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
    }

    return true;
  }

  Future<bool?> _showScheduleExactAlarmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.alarm),
        title: const Text('重要提示'),
        content: const Text(
          '定时播报需要"闹钟和提醒"权限才能准时推送。\n\n请确保以下设置已开启：\n• 设置 → 应用 → 轻氧天气 → 权限 → 闹钟和提醒\n\n点击"去检查"跳转到设置页面确认。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('已开启'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('去检查'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('需要$title'),
        content: Text('$message。请在系统设置中授予权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
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

  void _showTimePickerDialog(
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

  Future<void> _testBroadcast(
    BuildContext context,
    WidgetRef ref,
    bool isMorning,
    ScheduledBroadcastSettings settings,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在获取天气信息...'),
          ],
        ),
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
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.zero, child: child);
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: onChanged != null
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                    color: onChanged != null
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
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
