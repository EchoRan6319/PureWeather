import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';

class WeatherAlertCard extends StatefulWidget {
  final List<WeatherAlert> alerts;

  const WeatherAlertCard({super.key, required this.alerts});

  @override
  State<WeatherAlertCard> createState() => _WeatherAlertCardState();
}

class _WeatherAlertCardState extends State<WeatherAlertCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final alertColor = _getAlertColor(widget.alerts.first.level, colorScheme);
    final textColor = _getAlertTextColor(widget.alerts.first.level, colorScheme);
    final levelColor = _getLevelColor(widget.alerts.first.level, colorScheme);
    final backgroundColor = alertColor.withValues(alpha: 0.5);
    final elevation = 2.0;

    return Card(
      color: backgroundColor,
      elevation: elevation,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alertColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: levelColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.alerts.first.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: levelColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.alerts.length}条预警',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 16),
                ...widget.alerts.map((alert) => _AlertItem(alert: alert)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms)
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Color _getAlertColor(String level, ColorScheme colorScheme) {
    switch (level) {
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

  Color _getLevelColor(String level, ColorScheme colorScheme) {
    switch (level) {
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
}

class _AlertItem extends StatelessWidget {
  final WeatherAlert alert;

  const _AlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '发布时间: ${_formatPubTime(alert.pubTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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

}

