import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';
import 'scheduled_broadcast_screen.dart';

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
          _buildAppearanceSection(context, ref, themeSettings),
          _buildNotificationSection(context, ref, appSettings),
          _buildWeatherDisplaySection(context, ref, appSettings),
          _buildDataUpdateSection(context, ref, appSettings),
          _buildAdvancedSection(context, ref, appSettings),
          _buildAboutSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
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
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _insertDividers(context, children),
      ),
    );
  }

  List<Widget> _insertDividers(BuildContext context, List<Widget> children) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    ThemeSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '外观设置', Icons.palette_outlined),
        _buildSectionCard(
          context: context,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('主题模式'),
              subtitle: Text(_getThemeModeName(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showThemeModeDialog(context, ref, settings),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('主题颜色'),
              subtitle: Text(settings.useDynamicColor ? '跟随壁纸' : '自定义颜色'),
              trailing: _buildColorPreview(context, settings),
              onTap: () => _showColorPickerDialog(context, ref, settings),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.wallpaper_outlined),
              title: const Text('动态取色'),
              subtitle: const Text('根据壁纸自动生成主题色'),
              value: settings.useDynamicColor,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setUseDynamicColor(value);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPreview(BuildContext context, ThemeSettings settings) {
    return Container(
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
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '通知与播报', Icons.notifications_outlined),
        _buildSectionCard(
          context: context,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.warning_amber_outlined),
              title: const Text('天气预警通知'),
              subtitle: const Text('接收极端天气预警推送'),
              value: settings.notificationsEnabled,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('定时播报'),
              subtitle: const Text('设置每日定时推送天气信息'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => ScheduledBroadcastScreen.show(context, ref),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDisplaySection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '天气显示', Icons.thermostat_outlined),
        _buildSectionCard(
          context: context,
          children: [
            ListTile(
              leading: const Icon(Icons.device_thermostat_outlined),
              title: const Text('温度单位'),
              subtitle: Text(
                settings.temperatureUnit == 'celsius' ? '摄氏度 (°C)' : '华氏度 (°F)',
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showTemperatureUnitDialog(context, ref, settings),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('位置显示精度'),
              subtitle: Text(
                settings.locationAccuracyLevel == LocationAccuracyLevel.street
                    ? '街道级别'
                    : '区县级别',
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showLocationAccuracyDialog(context, ref, settings),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataUpdateSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '数据更新', Icons.sync_outlined),
        _buildSectionCard(
          context: context,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.autorenew_outlined),
              title: const Text('自动刷新'),
              subtitle: Text('每 ${settings.refreshInterval} 分钟自动更新'),
              value: settings.autoRefreshEnabled,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .setAutoRefreshEnabled(value);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('刷新间隔'),
              subtitle: Text('${settings.refreshInterval} 分钟'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showRefreshIntervalDialog(context, ref, settings),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '高级功能', Icons.tune_outlined),
        _buildSectionCard(
          context: context,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.swipe_outlined),
              title: const Text('预测式返回手势'),
              subtitle: const Text('返回时显示预览动画（Android 14+）'),
              value: settings.predictiveBackEnabled,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .setPredictiveBackEnabled(value);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '关于', Icons.info_outline),
        _buildSectionCard(
          context: context,
          children: [
            ListTile(
              leading: const Icon(Icons.apps_outlined),
              title: const Text('关于轻氧天气'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showAboutDialog(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('隐私政策'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('用户协议'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: const Text('检查更新'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已是最新版本'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ],
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '主题模式',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AppThemeMode.values.length,
                  itemBuilder: (context, index) {
                    final mode = AppThemeMode.values[index];
                    final isSelected = settings.themeMode == mode;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: !isSelected
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: RadioListTile<AppThemeMode>(
                        value: mode,
                        groupValue: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(themeProvider.notifier)
                                .setThemeMode(value);
                          }
                          Navigator.pop(ctx);
                        },
                        title: Text(_getThemeModeName(mode)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
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
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '选择主题颜色',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDynamicColorSection(context, ref, settings),
                    const SizedBox(height: 16),
                    _buildSectionTitle(context, '预设颜色'),
                    const SizedBox(height: 8),
                    _buildPresetColors(context, settings, selectedColor, (
                      color,
                    ) {
                      setState(() {
                        selectedColor = color;
                        hexController.text =
                            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildSectionTitle(context, '自定义颜色'),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
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

        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dynamicColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrentDynamic
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                ),
                title: const Text('壁纸取色'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '检测颜色: #${dynamicColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    Text(
                      '状态: ${_getDynamicColorStatus(lightDynamic)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: isCurrentDynamic
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  ref.read(themeProvider.notifier).setUseDynamicColor(true);
                  Navigator.pop(context);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              if (isCurrentDynamic)
                _buildDynamicColorDiagnostic(
                  context,
                  lightDynamic,
                  darkDynamic,
                ),
            ],
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

  String _getDynamicColorStatus(ColorScheme? colorScheme) {
    if (colorScheme == null) return '不支持';
    final primary = colorScheme.primary;
    if (primary == const Color(0xFF0054D6)) {
      return '⚠️ 可能使用默认颜色';
    }
    return '✓ 正常';
  }

  Widget _buildDynamicColorDiagnostic(
    BuildContext context,
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '颜色详情',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildColorDetailRow(context, '主色', lightDynamic?.primary),
          _buildColorDetailRow(context, '主色容器', lightDynamic?.primaryContainer),
          _buildColorDetailRow(context, '次色', lightDynamic?.secondary),
          _buildColorDetailRow(context, '三色', lightDynamic?.tertiary),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '如果颜色不随壁纸变化，请检查系统设置中的"壁纸颜色"或"Material You"选项是否启用',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildColorDetailRow(BuildContext context, String name, Color? color) {
    if (color == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildCustomColorPicker(
    BuildContext context,
    Color selectedColor,
    TextEditingController hexController,
    Function(Color) onColorSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '十六进制颜色代码',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
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
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '刷新间隔',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: intervals.length,
                  itemBuilder: (context, index) {
                    final interval = intervals[index];
                    final isSelected = settings.refreshInterval == interval;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: !isSelected
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: RadioListTile<int>(
                        value: interval,
                        groupValue: settings.refreshInterval,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .setRefreshInterval(value);
                          }
                          Navigator.pop(ctx);
                        },
                        title: Text('$interval 分钟'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showTemperatureUnitDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final units = [
      ('celsius', '摄氏度', '°C', '温度显示为摄氏度'),
      ('fahrenheit', '华氏度', '°F', '温度显示为华氏度'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '温度单位',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final (value, name, symbol, desc) = units[index];
                    final isSelected = settings.temperatureUnit == value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: !isSelected
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: RadioListTile<String>(
                        value: value,
                        groupValue: settings.temperatureUnit,
                        onChanged: (selectedValue) {
                          if (selectedValue != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .setTemperatureUnit(selectedValue);
                          }
                          Navigator.pop(ctx);
                        },
                        title: Text('$name ($symbol)'),
                        subtitle: Text(desc),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showLocationAccuracyDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final options = [
      (LocationAccuracyLevel.district, '展示区/县', '定位到行政区级别'),
      (LocationAccuracyLevel.street, '展示附近地标/街道', '精确定位到街道级别'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '位置显示',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final (level, title, subtitle) = options[index];
                    final isSelected = settings.locationAccuracyLevel == level;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: !isSelected
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: RadioListTile<LocationAccuracyLevel>(
                        value: level,
                        groupValue: settings.locationAccuracyLevel,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .setLocationAccuracyLevel(value);
                          }
                          Navigator.pop(ctx);
                        },
                        title: Text(title),
                        subtitle: Text(subtitle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('需要通知权限'),
        content: const Text('轻氧天气需要通知权限才能推送天气预警。请在系统设置中授予通知权限。'),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '轻氧天气',
      applicationVersion: '2.2',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/icons/app_icon.png', width: 64, height: 64),
      ),
      children: [
        const Text('一款简洁美观的天气应用'),
        const SizedBox(height: 8),
        const Text('使用 Material You Design 设计语言'),
        const SizedBox(height: 8),
        const Text('数据来源：和风天气、彩云天气'),
        const SizedBox(height: 16),
        Builder(
          builder: (context) => InkWell(
            onTap: () => launchUrl(
              Uri.parse('https://github.com/EchoRan/PureWeather'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'https://github.com/EchoRan/PureWeather',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
