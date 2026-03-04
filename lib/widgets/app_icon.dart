import 'package:flutter/material.dart';

/// 应用图标绘制组件
/// 
/// 绘制与 Android 自适应图标相同的太阳半遮云图案
class AppIcon extends StatelessWidget {
  /// 图标大小
  final double size;
  /// 背景颜色
  final Color? backgroundColor;
  /// 太阳颜色
  final Color? sunColor;
  /// 云朵颜色
  final Color? cloudColor;

  /// 构造函数
  /// 
  /// [size]: 图标大小，默认80
  /// [backgroundColor]: 背景颜色，默认使用主题的primaryContainer
  /// [sunColor]: 太阳颜色，默认使用主题的primary
  /// [cloudColor]: 云朵颜色，默认使用主题的secondary
  const AppIcon({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.sunColor,
    this.cloudColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.primaryContainer.withValues(alpha: 0.5);
    final sColor = sunColor ?? colorScheme.primary;
    final cColor = cloudColor ?? colorScheme.secondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Container(
        width: size,
        height: size,
        color: bgColor,
        child: CustomPaint(
          size: Size(size, size),
          painter: _AppIconPainter(
            sunColor: sColor,
            cloudColor: cColor,
          ),
        ),
      ),
    );
  }
}

/// 应用图标绘制器
/// 
/// 负责绘制太阳和云朵的具体图形
class _AppIconPainter extends CustomPainter {
  /// 太阳颜色
  final Color sunColor;
  /// 云朵颜色
  final Color cloudColor;

  /// 构造函数
  /// 
  /// [sunColor]: 太阳颜色
  /// [cloudColor]: 云朵颜色
  _AppIconPainter({
    required this.sunColor,
    required this.cloudColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算缩放比例
    final double scale = size.width / 108;
    canvas.scale(scale, scale);

    // 图标主体偏移 (25, 30)
    canvas.translate(25, 30);

    // 绘制太阳 - 偏移 (3, 3)
    _drawSun(canvas, 3, 3);

    // 绘制云朵 - 偏移 (12, 14)
    _drawCloud(canvas, 12, 14);
  }

  /// 绘制太阳
  /// 
  /// [canvas]: 画布
  /// [offsetX]: X轴偏移
  /// [offsetY]: Y轴偏移
  void _drawSun(Canvas canvas, double offsetX, double offsetY) {
    canvas.save();
    canvas.translate(offsetX, offsetY);

    // 光芒画笔
    final paint = Paint()
      ..color = sunColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 光芒坐标点
    final List<Offset> rays = [
      const Offset(15, 1), const Offset(15, 4),
      const Offset(15, 26), const Offset(15, 29),
      const Offset(1, 15), const Offset(4, 15),
      const Offset(26, 15), const Offset(29, 15),
      const Offset(5.5, 5.5), const Offset(7.8, 7.8),
      const Offset(22.2, 22.2), const Offset(24.5, 24.5),
      const Offset(5.5, 24.5), const Offset(7.8, 22.2),
      const Offset(22.2, 7.8), const Offset(24.5, 5.5),
    ];

    // 绘制光芒
    for (int i = 0; i < rays.length; i += 2) {
      canvas.drawLine(rays[i], rays[i + 1], paint);
    }

    // 绘制太阳中心圆
    final circlePaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(15, 15), 7, circlePaint);

    canvas.restore();
  }

  /// 绘制云朵
  /// 
  /// [canvas]: 画布
  /// [offsetX]: X轴偏移
  /// [offsetY]: Y轴偏移
  void _drawCloud(Canvas canvas, double offsetX, double offsetY) {
    canvas.save();
    canvas.translate(offsetX, offsetY);

    // 云朵画笔
    final paint = Paint()
      ..color = cloudColor
      ..style = PaintingStyle.fill;

    // 云朵路径
    final path = Path();
    path.moveTo(36, 20);
    path.cubicTo(36, 15, 32, 11, 27, 11);
    path.cubicTo(26.5, 11, 26, 11.1, 25.5, 11.2);
    path.cubicTo(24, 6.7, 19.7, 3.5, 14.7, 3.5);
    path.cubicTo(8.3, 3.5, 3.2, 8.7, 3.2, 15);
    path.cubicTo(3.2, 15.4, 3.2, 15.8, 3.3, 16.2);
    path.cubicTo(1.9, 16.9, 0, 19.3, 0, 22);
    path.cubicTo(0, 25.3, 2.7, 28, 6, 28);
    path.lineTo(36, 28);
    path.cubicTo(39.3, 28, 42, 25.3, 42, 22);
    path.cubicTo(42, 18.7, 39.3, 20, 36, 20);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
