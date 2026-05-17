import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

    final tokens = context.uiTokens;
    final firstAlert = widget.alerts.first;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final padding = isLargeScreen ? 20.0 : 16.0;
    final spacing = isLargeScreen ? 12.0 : 8.0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      firstAlert.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.selectedBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: tokens.selectedBorder),
                    ),
                    child: Text(
                      '${context.tr(firstAlert.level)}${context.tr('预警')}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: tokens.selectedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Padding(
                padding: EdgeInsets.only(left: 28),
                child: Text(
                  context.tr(
                    '{count}条预警',
                    args: {'count': widget.alerts.length},
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (_isExpanded) ...[
                SizedBox(height: padding),
                Container(
                  height: 1,
                  color: tokens.divider,
                ).animate().fadeIn(duration: 200.ms),
                SizedBox(height: padding),
                ...widget.alerts.map(
                  (alert) => _AlertItem(alert: alert)
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
}

class _AlertItem extends StatelessWidget {
  final WeatherAlert alert;

  const _AlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.text, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            context.tr(
              '发布时间: {time}',
              args: {'time': _formatPubTime(context, alert.pubTime)},
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
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

      if (difference == 0) return '${context.tr('今天')} $timeStr';
      if (difference == 1) return '${context.tr('昨天')} $timeStr';
      if (difference == 2) return '${context.tr('前天')} $timeStr';
      final dateFormat = DateFormat('MM-dd HH:mm');
      return dateFormat.format(localTime);
    } catch (_) {
      return pubTime;
    }
  }
}
