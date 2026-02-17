import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_models.dart';

class AirQualityCard extends StatelessWidget {
  final AirQuality airQuality;

  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.air,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '空气质量',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAqiCircle(context),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airQuality.category,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getAqiColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '主要污染物: ${_getMainPollutant()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPollutantsGrid(context),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildAqiCircle(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            _getAqiColor(context).withValues(alpha: 0.3),
            _getAqiColor(context),
            _getAqiColor(context).withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
            child: Text(
              airQuality.aqi,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getAqiColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollutantsGrid(BuildContext context) {
    final pollutants = [
      ('PM2.5', airQuality.pm2p5, 'μg/m³'),
      ('PM10', airQuality.pm10, 'μg/m³'),
      ('O₃', airQuality.o3, 'μg/m³'),
      ('NO₂', airQuality.no2, 'μg/m³'),
      ('SO₂', airQuality.so2, 'μg/m³'),
      ('CO', airQuality.co, 'mg/m³'),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pollutants
              .take(3)
              .map((p) => _buildPollutantItem(context, p))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pollutants
              .skip(3)
              .map((p) => _buildPollutantItem(context, p))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPollutantItem(BuildContext context, (String, String, String) p) {
    return Column(
      children: [
        Text(
          p.$1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          p.$2,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          p.$3,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getAqiColor(BuildContext context) {
    final aqi = int.tryParse(airQuality.aqi) ?? 0;

    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFFFFEB3B);
    if (aqi <= 150) return const Color(0xFFFF9800);
    if (aqi <= 200) return const Color(0xFFF44336);
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF795548);
  }

  String _getMainPollutant() {
    final values = {
      'PM2.5': double.tryParse(airQuality.pm2p5) ?? 0,
      'PM10': double.tryParse(airQuality.pm10) ?? 0,
      'O₃': double.tryParse(airQuality.o3) ?? 0,
      'NO₂': double.tryParse(airQuality.no2) ?? 0,
      'SO₂': double.tryParse(airQuality.so2) ?? 0,
    };

    var maxKey = 'PM2.5';
    var maxValue = 0.0;

    values.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });

    return maxKey;
  }
}
