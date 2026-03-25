import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Material You 风格的设置分组组件
///
/// 遵循 Material 3 设计规范，提供统一的视觉风格和交互体验
class SettingsSection extends StatelessWidget {
  /// 分组标题
  final String title;

  /// 分组图标
  final IconData icon;

  /// 子组件列表
  final List<Widget> children;

  /// 是否显示分隔线
  final bool showDividers;

  /// 动画延迟（毫秒）
  final int animationDelay;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.showDividers = true,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.uiTokens;

    // 构建带分隔线的子组件列表
    final List<Widget> childrenWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      childrenWithDividers.add(children[i]);
      if (showDividers && i < children.length - 1) {
        childrenWithDividers.add(
          Divider(
            height: 1,
            indent: 56, // 与图标对齐
            endIndent: 16,
            color: tokens.divider,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr(title),
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // 内容区域
          Container(
            decoration: BoxDecoration(
              color: tokens.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: childrenWithDividers,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: animationDelay),
      duration: 300.ms,
    ).slideY(
      delay: Duration(milliseconds: animationDelay),
      begin: 0.02,
      duration: 300.ms,
    );
  }
}
