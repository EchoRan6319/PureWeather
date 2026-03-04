import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';

class WeatherAlertCard extends StatelessWidget {
  final List<WeatherAlert> alerts;

  const WeatherAlertCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final alertColor = _getAlertColor(alerts.first.level, colorScheme);
    final textColor = _getAlertTextColor(alerts.first.level, colorScheme);

    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: alertColor,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              childrenPadding: EdgeInsets.zero,
              leading: Icon(Icons.warning_amber_rounded, color: textColor),
              title: Text(
                alerts.first.title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                '${alerts.length}条预警',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              collapsedIconColor: textColor,
              iconColor: textColor,
              children: alerts
                  .map(
                    (alert) =>
                        _AlertItem(alert: alert, parentColor: alertColor),
                  )
                  .toList(),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
        .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeInOut)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeInOut,
        );
  }

  Color _getAlertColor(String level, ColorScheme colorScheme) {
    switch (level) {
      case '红色':
        return colorScheme.errorContainer;
      case '橙色':
        return Color.lerp(colorScheme.tertiaryContainer, Colors.orange.withValues(alpha: 0.1), 0.5)!;
      case '黄色':
        return Color.lerp(colorScheme.secondaryContainer, Colors.yellow.withValues(alpha: 0.1), 0.5)!;
      case '蓝色':
        return colorScheme.primaryContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getAlertTextColor(String level, ColorScheme colorScheme) {
    switch (level) {
      case '红色':
        return colorScheme.onErrorContainer;
      case '橙色':
        return colorScheme.onTertiaryContainer;
      case '黄色':
        return colorScheme.onSecondaryContainer;
      case '蓝色':
        return colorScheme.onPrimaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

class _AlertItem extends StatelessWidget {
  final WeatherAlert alert;
  final Color parentColor;

  const _AlertItem({required this.alert, required this.parentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: parentColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(Theme.of(context).colorScheme),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.level,
                  style: TextStyle(
                    color: _getLevelTextColor(Theme.of(context).colorScheme),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.typeName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: _getAlertTextColor(alert.level, Theme.of(context).colorScheme)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getAlertTextColor(alert.level, Theme.of(context).colorScheme).withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '发布时间: ${_formatPubTime(alert.pubTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getAlertTextColor(alert.level, Theme.of(context).colorScheme).withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPubTime(String pubTime) {
    try {
      final dateTime = DateTime.parse(pubTime);
      final localTime = dateTime.toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final alertDate = DateTime(
        localTime.year,
        localTime.month,
        localTime.day,
      );
      final difference = today.difference(alertDate).inDays;

      final timeFormat = DateFormat('HH:mm');
      final timeStr = timeFormat.format(localTime);

      if (difference == 0) {
        return '今天 $timeStr';
      } else if (difference == 1) {
        return '昨天 $timeStr';
      } else if (difference == 2) {
        return '前天 $timeStr';
      } else {
        final dateFormat = DateFormat('MM-dd HH:mm');
        return dateFormat.format(localTime);
      }
    } catch (e) {
      return pubTime;
    }
  }

  Color _getLevelColor(ColorScheme colorScheme) {
    switch (alert.level) {
      case '红色':
        return colorScheme.error;
      case '橙色':
        return Colors.orange;
      case '黄色':
        return Colors.yellow.shade700;
      case '蓝色':
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }

  Color _getAlertTextColor(String level, ColorScheme colorScheme) {
    switch (level) {
      case '红色':
        return colorScheme.onErrorContainer;
      case '橙色':
        return colorScheme.onTertiaryContainer;
      case '黄色':
        return colorScheme.onSecondaryContainer;
      case '蓝色':
        return colorScheme.onPrimaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  Color _getLevelTextColor(ColorScheme colorScheme) {
    switch (alert.level) {
      case '红色':
        return colorScheme.onError;
      case '橙色':
      case '蓝色':
        return Colors.white;
      case '黄色':
        return Colors.black;
      default:
        return Colors.white;
    }
  }
}
