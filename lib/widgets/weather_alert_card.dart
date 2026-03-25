import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../app_localizations.dart';
import '../models/weather_models.dart';
import '../core/theme/app_theme.dart';

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
    final tokens = context.uiTokens;
    final alertColor = _getAlertColor(widget.alerts.first.level, colorScheme);
    final levelColor = _getLevelColor(widget.alerts.first.level, colorScheme);
    final backgroundColor = Color.alphaBlend(
      alertColor.withValues(alpha: 0.16),
      tokens.dangerBackground,
    );

    // 响应式布局参数
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final padding = isLargeScreen ? 24.0 : 16.0;
    final iconSize = isLargeScreen ? 24.0 : 20.0;
    final spacing = isLargeScreen ? 12.0 : 8.0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.75),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        child: Padding(
          padding: EdgeInsets.only(
            top: padding,
            left: padding,
            right: padding,
            bottom: padding * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: iconSize,
                    color: levelColor,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      widget.alerts.first.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: isLargeScreen ? 18 : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing,
                      vertical: isLargeScreen ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: levelColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      context.tr(widget.alerts.first.level),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: iconSize,
                    color: levelColor,
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Padding(
                padding: EdgeInsets.only(left: iconSize + spacing),
                child: Text(
                  context.tr(
                    '{count}条预警',
                    args: {'count': widget.alerts.length},
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isLargeScreen ? 14 : null,
                  ),
                ),
              ),
              if (_isExpanded) ...[
                SizedBox(height: padding),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ).animate().fadeIn(duration: 300.ms),
                SizedBox(height: padding),
                ...widget.alerts.map(
                  (alert) =>
                      _AlertItem(alert: alert, isLargeScreen: isLargeScreen)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms)
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 300.ms,
                            delay: 100.ms,
                          ),
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
}

class _AlertItem extends StatelessWidget {
  final WeatherAlert alert;
  final bool isLargeScreen;

  const _AlertItem({required this.alert, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = isLargeScreen ? 8.0 : 4.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: isLargeScreen ? 14 : null,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            context.tr(
              '发布时间: {time}',
              args: {'time': _formatPubTime(context, alert.pubTime)},
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isLargeScreen ? 12 : 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPubTime(BuildContext context, String pubTime) {
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
        return '${context.tr('今天')} $timeStr';
      } else if (difference == 1) {
        return '${context.tr('昨天')} $timeStr';
      } else if (difference == 2) {
        return '${context.tr('前天')} $timeStr';
      } else {
        final dateFormat = DateFormat('MM-dd HH:mm');
        return dateFormat.format(localTime);
      }
    } catch (e) {
      return pubTime;
    }
  }
}
