import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Material Design 3 风格的底部弹窗组件
///
/// 遵循 Material 3 设计规范：
/// - 使用简单的 Column 布局，自适应高度
/// - 顶部圆角 28dp
/// - 包含拖动指示器和标题
/// - 内容区域使用 ListView 或 Column
class SettingsBottomSheet extends StatelessWidget {
  /// 弹窗标题
  final String title;

  /// 子组件列表
  final List<Widget> children;

  /// 底部操作按钮（可选）
  final Widget? bottomAction;

  const SettingsBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top;
    final bottomInset = mediaQuery.viewPadding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    const topExtraClearance = 30.0;
    final topSafeOffset = topInset + topExtraClearance;
    final maxSheetHeight = mediaQuery.size.height * 0.9;
    final contentMaxHeight = mediaQuery.size.height * 0.9;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarContrastEnforced: false,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Padding(
        padding: EdgeInsets.only(
          top: topSafeOffset,
          left: mediaQuery.viewPadding.left,
          right: mediaQuery.viewPadding.right,
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxSheetHeight > 0
                  ? maxSheetHeight
                  : mediaQuery.size.height,
            ),
            child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                    context.tr(title),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // 内容区域 - 使用 Flexible 包裹 ListView 以适应不同高度
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: contentMaxHeight > 0
                          ? contentMaxHeight
                          : mediaQuery.size.height,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: children,
                    ),
                  ),
                ),
                // 底部操作按钮
                if (bottomAction != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      24 + bottomInset,
                    ),
                    child: bottomAction,
                  )
                else
                  SizedBox(height: bottomInset),
              ],
            ),
          ),
          ),
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

/// Material Design 3 风格的选择项组件
///
/// 使用 RadioListTile 实现，遵循 Material 3 规范：
/// - 自适应高度（单行 56dp，双行 72dp）
/// - 图标 24dp，与文字间距 16dp
/// - 选中状态使用主题色
/// - 圆角背景（选中时）
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

  /// 选项值（用于 RadioListTile）
  final dynamic value;

  /// 当前选中的值（用于 RadioListTile）
  final dynamic groupValue;

  const SettingsSelectionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
    this.value,
    this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.uiTokens;

    // 使用 Material 3 推荐的 RadioListTile
    // 它自动处理：
    // - 自适应高度（根据是否有 subtitle）
    // - 图标与文字的对齐
    // - 选中状态样式
    // - 触摸反馈
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? tokens.selectedBackground : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? tokens.selectedBorder : tokens.cardBorder,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 左侧图标
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? tokens.selectedForeground
                      : enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                const SizedBox(width: 16),
                // 中间内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr(title),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? tokens.selectedForeground
                              : enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.tr(subtitle!),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? tokens.selectedForeground.withValues(
                                        alpha: 0.78,
                                      )
                                    : enabled
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.38,
                                      ),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 右侧选中标记
                if (isSelected)
                  Icon(Icons.check_circle, color: tokens.selectedForeground),
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
/// 使用 showModalBottomSheet 显示 Material 3 风格的弹窗
Future<void> showSettingsBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  Widget? bottomAction,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SettingsBottomSheet(
      title: title,
      bottomAction: bottomAction,
      children: children,
    ),
  );
}
