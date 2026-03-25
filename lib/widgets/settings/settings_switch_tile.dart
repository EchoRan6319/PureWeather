import 'package:flutter/material.dart';
import '../../app_localizations.dart';

/// Material You 风格的设置开关项组件
///
/// 遵循 Material 3 设计规范，提供统一的视觉风格和交互体验
class SettingsSwitchTile extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 副标题（可选）
  final String? subtitle;

  /// 开关值
  final bool value;

  /// 开关值变化回调
  final ValueChanged<bool>? onChanged;

  /// 背景色（可选，默认使用surface）
  final Color? backgroundColor;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final enabled = onChanged != null;

    final iconColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface.withValues(alpha: 0.38);

    final titleColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    final subtitleColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          child: Row(
            children: [
              // 图标区域 - 固定尺寸确保对齐
              SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              // 内容区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr(title),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        context.tr(subtitle!),
                        style: textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 开关区域
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
