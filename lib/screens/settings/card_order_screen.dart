import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';

/// 天气卡片排序页面
///
/// 遵循 Material You 设计规范，提供统一的视觉风格和交互体验
class CardOrderScreen {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

  final Map<String, ({String title, IconData icon, String description})>
  _cardInfo = {
    'hourly': (
      title: '24小时预报',
      icon: Icons.schedule_outlined,
      description: '显示未来24小时的天气变化趋势',
    ),
    'daily': (
      title: '7天预报',
      icon: Icons.calendar_month_outlined,
      description: '显示未来7天的天气概况',
    ),
    'airQuality': (
      title: '空气质量',
      icon: Icons.air_outlined,
      description: '显示当前空气质量指数和污染物信息',
    ),
    'details': (
      title: '详细信息',
      icon: Icons.info_outline,
      description: '显示湿度、气压、能见度等详细数据',
    ),
    'indices': (
      title: '生活指数',
      icon: Icons.tips_and_updates_outlined,
      description: '显示穿衣、运动、洗车等生活建议',
    ),
  };

  @override
  void initState() {
    super.initState();
    // 确保使用有效的顺序
    const validOrder = ['hourly', 'daily', 'airQuality', 'details', 'indices'];
    final savedOrder = ref.read(settingsProvider).weatherCardOrder;

    // 验证顺序
    final hasAllValidCards = savedOrder.every(
      (card) => validOrder.contains(card),
    );
    final hasCorrectLength = savedOrder.length == validOrder.length;

    if (hasAllValidCards && hasCorrectLength) {
      _currentOrder = List.from(savedOrder);
    } else {
      _currentOrder = List.from(validOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Text(
                          '天气卡片排序',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.restore_outlined),
                        tooltip: '恢复默认',
                        onPressed: () {
                          setState(() {
                            _currentOrder = [
                              'hourly',
                              'daily',
                              'airQuality',
                              'details',
                              'indices',
                            ];
                          });
                          ref
                              .read(settingsProvider.notifier)
                              .setWeatherCardOrder(_currentOrder);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.uiTokens.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.uiTokens.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '按住并拖动卡片右侧的图标，调整它们在天气详情页中的显示顺序。',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                  final info = _cardInfo[key]!;

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
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('完成'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
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
            // 图标容器
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
            // 内容区域
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
            // 拖动手柄
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
