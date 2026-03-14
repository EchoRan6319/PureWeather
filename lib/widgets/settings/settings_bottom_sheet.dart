import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Material You 风格的底部弹窗组件
///
/// 遵循 Material 3 设计规范，提供统一的视觉风格和交互体验
/// 支持根据内容动态调整高度
class SettingsBottomSheet extends StatefulWidget {
  /// 弹窗标题
  final String title;

  /// 子组件列表
  final List<Widget> children;

  /// 底部操作按钮（可选）
  final Widget? bottomAction;

  /// 每个选项的估计高度（用于计算初始高度）
  final double itemEstimatedHeight;

  /// 头部区域高度（拖动条 + 标题）
  final double headerHeight;

  /// 底部内边距
  final double bottomPadding;

  const SettingsBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.bottomAction,
    this.itemEstimatedHeight = 72.0, // 每个选项估计高度
    this.headerHeight = 100.0, // 拖动条(24) + 标题(76)
    this.bottomPadding = 24.0,
  });

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late double _initialChildSize;
  late double _minChildSize;
  late double _maxChildSize;

  @override
  void initState() {
    super.initState();
    _calculateSizes();
  }

  void _calculateSizes() {
    // 计算内容总高度
    final contentHeight = widget.children.length * widget.itemEstimatedHeight;
    final totalHeight = widget.headerHeight + contentHeight + widget.bottomPadding;
    
    // 获取屏幕高度（使用一个合理的默认值，实际会在build中重新计算）
    const screenHeight = 800.0; // 默认屏幕高度
    
    // 计算比例
    double calculatedSize = totalHeight / screenHeight;
    
    // 限制在合理范围内
    _initialChildSize = calculatedSize.clamp(0.25, 0.6);
    _minChildSize = calculatedSize.clamp(0.2, 0.4);
    _maxChildSize = 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 根据实际屏幕高度重新计算
    final contentHeight = widget.children.length * widget.itemEstimatedHeight;
    final totalHeight = widget.headerHeight + contentHeight + widget.bottomPadding;
    
    double calculatedSize = totalHeight / screenHeight;
    _initialChildSize = calculatedSize.clamp(0.25, 0.6);
    _minChildSize = (_initialChildSize * 0.8).clamp(0.2, 0.4);

    return DraggableScrollableSheet(
      initialChildSize: _initialChildSize,
      minChildSize: _minChildSize,
      maxChildSize: _maxChildSize,
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
              // 拖动指示器
              _buildHandle(context),
              // 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // 内容区域
              Flexible(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  children: widget.children,
                ),
              ),
              // 底部操作按钮
              if (widget.bottomAction != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: widget.bottomAction,
                ),
            ],
          ),
        );
      },
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

/// Material You 风格的选择项组件
class SettingsSelectionItem extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题（可选）
  final String? subtitle;

  /// 图标
  final IconData icon;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否启用
  final bool enabled;

  const SettingsSelectionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerLow;

    final iconColor = isSelected
        ? colorScheme.onSecondaryContainer
        : enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withValues(alpha: 0.38);

    final titleColor = isSelected
        ? colorScheme.onSecondaryContainer
        : enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.38);

    final subtitleColor = isSelected
        ? colorScheme.onSecondaryContainer.withValues(alpha: 0.7)
        : enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withValues(alpha: 0.38);

    final bool hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 44, // 固定高度确保所有选项高度一致
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: hasSubtitle
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),
                        if (hasSubtitle)
                          Text(
                            subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                              height: 1.2,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.onSecondaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: key.hashCode % 5 * 50),
      duration: 200.ms,
    );
  }
}

/// 显示设置底部弹窗的便捷方法
/// 
/// 自动根据内容数量计算合适的弹窗高度
Future<void> showSettingsBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  Widget? bottomAction,
  double? itemEstimatedHeight,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SettingsBottomSheet(
      title: title,
      bottomAction: bottomAction,
      itemEstimatedHeight: itemEstimatedHeight ?? 72.0,
      children: children,
    ),
  );
}
