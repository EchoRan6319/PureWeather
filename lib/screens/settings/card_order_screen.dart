import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/settings/settings.dart';

/// 天气卡片排序页面
///
/// 遵循 Aurora UI 设计规范，提供统一的视觉风格和交互体验
class CardOrderScreen {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CardOrderBottomSheet(),
    );
  }
}

class _CardOrderBottomSheet extends ConsumerStatefulWidget {
  const _CardOrderBottomSheet();

  @override
  ConsumerState<_CardOrderBottomSheet> createState() =>
      _CardOrderBottomSheetState();
}

class _CardOrderBottomSheetState extends ConsumerState<_CardOrderBottomSheet> {
  late List<String> _currentOrder;

  @override
  void initState() {
    super.initState();
    const validOrder = ['hourly', 'daily', 'airQuality', 'details', 'indices'];
    final savedOrder = ref.read(settingsProvider).weatherCardOrder;

    final hasAllValidCards = savedOrder.every(
      (card) => validOrder.contains(card),
    );
    final hasCorrectLength = savedOrder.length == validOrder.length;

    _currentOrder = hasAllValidCards && hasCorrectLength
        ? List.from(savedOrder)
        : List.from(validOrder);
  }

  @override
  Widget build(BuildContext context) {
    final cardInfo =
        <String, ({String title, IconData icon, String description})>{
          'hourly': (
            title: context.tr('24小时预报'),
            icon: LucideIcons.clock,
            description: context.tr('显示未来24小时的天气变化趋势'),
          ),
          'daily': (
            title: context.tr('7天预报'),
            icon: LucideIcons.calendar,
            description: context.tr('显示未来7天的天气概况'),
          ),
          'airQuality': (
            title: context.tr('空气质量'),
            icon: LucideIcons.wind,
            description: context.tr('显示当前空气质量指数和污染物信息'),
          ),
          'details': (
            title: context.tr('详细信息'),
            icon: LucideIcons.info,
            description: context.tr('显示湿度、气压、能见度等详细数据'),
          ),
          'indices': (
            title: context.tr('生活指数'),
            icon: LucideIcons.lightbulb,
            description: context.tr('显示穿衣、运动、洗车等生活建议'),
          ),
        };

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsBottomSheet(
      title: '天气卡片排序',
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
          child: Text(context.tr('完成')),
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(LucideIcons.undo2),
            tooltip: context.tr('恢复默认'),
            onPressed: _resetOrder,
          ),
        ),
        _InfoCard(
          child: Row(
            children: [
              Icon(LucideIcons.info, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('按住并拖动卡片右侧的图标，调整它们在天气详情页中的显示顺序。'),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.54,
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _currentOrder.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _currentOrder.removeAt(oldIndex);
                _currentOrder.insert(newIndex, item);
              });
              ref
                  .read(settingsProvider.notifier)
                  .setWeatherCardOrder(_currentOrder);
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    elevation: 0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final key = _currentOrder[index];
              final info = cardInfo[key]!;

              return _ReorderableCardItem(
                key: ValueKey(key),
                index: index,
                title: info.title,
                description: info.description,
                icon: info.icon,
              );
            },
          ),
        ),
      ],
    );
  }

  void _resetOrder() {
    setState(() {
      _currentOrder = ['hourly', 'daily', 'airQuality', 'details', 'indices'];
    });
    ref.read(settingsProvider.notifier).setWeatherCardOrder(_currentOrder);
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
      child: child,
    );
  }
}

/// 可重排序的卡片项组件
class _ReorderableCardItem extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final IconData icon;

  const _ReorderableCardItem({
    required super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: context.tr('拖动排序'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.gripVertical,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
