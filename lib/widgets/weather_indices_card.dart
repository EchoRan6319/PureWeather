import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_localizations.dart';
import '../models/weather_models.dart';
import '../core/theme/app_theme.dart';

class WeatherIndicesCard extends StatelessWidget {
  final List<WeatherIndices> indices;

  const WeatherIndicesCard({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) return const SizedBox.shrink();
    final tokens = context.uiTokens;

    // 只取前6个指数
    final displayIndices = indices.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.lightbulb,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('生活指数'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 两行三列布局
            Column(
              children: [
                // 第一行
                Row(
                  children: [
                    Expanded(child: _IndexItem(index: displayIndices[0])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: displayIndices.length > 1
                          ? _IndexItem(index: displayIndices[1])
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: displayIndices.length > 2
                          ? _IndexItem(index: displayIndices[2])
                          : const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 第二行
                Row(
                  children: [
                    Expanded(
                      child: displayIndices.length > 3
                          ? _IndexItem(index: displayIndices[3])
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: displayIndices.length > 4
                          ? _IndexItem(index: displayIndices[4])
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: displayIndices.length > 5
                          ? _IndexItem(index: displayIndices[5])
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _IndexItem extends StatelessWidget {
  final WeatherIndices index;

  const _IndexItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIndexIcon(index.type),
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(index.name),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(index.category),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIndexIcon(String type) {
    switch (type) {
      case '1':
        return LucideIcons.footprints;
      case '2':
        return LucideIcons.car;
      case '3':
        return LucideIcons.shirt;
      case '5':
        return LucideIcons.droplets;
      case '6':
        return LucideIcons.sun;
      case '7':
        return LucideIcons.heartPulse;
      case '8':
        return LucideIcons.umbrella;
      case '9':
        return LucideIcons.flower2;
      default:
        return LucideIcons.info;
    }
  }
}
