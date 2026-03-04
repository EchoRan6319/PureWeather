import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_models.dart';

/// 空气质量卡片组件
/// 
/// 显示空气质量指数和各种污染物数据
class AirQualityCard extends StatelessWidget {
  /// 空气质量数据
  final AirQuality airQuality;

  /// 构造函数
  /// 
  /// [airQuality]: 空气质量数据
  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
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
            const SizedBox(height: 10),
            // AQI指数和空气质量等级
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
            // 污染物数据网格
            _buildPollutantsGrid(context),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  /// 构建AQI圆形显示
  /// 
  /// [context]: 上下文
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

  /// 构建污染物数据网格
  /// 
  /// [context]: 上下文
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
          children: pollutants
              .take(3)
              .map((p) => Expanded(child: _buildPollutantItem(context, p)))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: pollutants
              .skip(3)
              .map((p) => Expanded(child: _buildPollutantItem(context, p)))
              .toList(),
        ),
      ],
    );
  }

  /// 构建单个污染物数据项
  /// 
  /// [context]: 上下文
  /// [p]: 污染物数据 (名称, 值, 单位)
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

  /// 根据AQI值获取对应颜色
  /// 
  /// [context]: 上下文
  Color _getAqiColor(BuildContext context) {
    final aqi = int.tryParse(airQuality.aqi) ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    if (aqi <= 50) return Colors.green.shade400; // 优
    if (aqi <= 100) return Colors.yellow.shade600; // 良
    if (aqi <= 150) return Colors.orange.shade400; // 轻度污染
    if (aqi <= 200) return colorScheme.error; // 中度污染
    if (aqi <= 300) return Colors.purple.shade400; // 重度污染
    return Colors.brown.shade400; // 严重污染
  }

  /// 获取主要污染物
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
