import 'package:flutter/material.dart';
import 'dart:io';

/// 自定义颜色类，封装了应用中使用的所有颜色
/// 
/// 这个类扩展了Flutter的ColorScheme，提供了更便捷的颜色访问方式
class CustomColors {
  /// 种子颜色，用于生成整个颜色方案
  final Color seedColor;
  
  /// 主要颜色，用于关键UI元素
  final Color primary;
  
  /// 主要颜色上的文字颜色
  final Color onPrimary;
  
  /// 主要容器颜色，用于背景
  final Color primaryContainer;
  
  /// 主要容器上的文字颜色
  final Color onPrimaryContainer;
  
  /// 次要颜色，用于辅助UI元素
  final Color secondary;
  
  /// 次要颜色上的文字颜色
  final Color onSecondary;
  
  /// 次要容器颜色，用于背景
  final Color secondaryContainer;
  
  /// 次要容器上的文字颜色
  final Color onSecondaryContainer;
  
  /// 第三颜色，用于强调UI元素
  final Color tertiary;
  
  /// 第三颜色上的文字颜色
  final Color onTertiary;
  
  /// 第三容器颜色，用于背景
  final Color tertiaryContainer;
  
  /// 第三容器上的文字颜色
  final Color onTertiaryContainer;
  
  /// 错误颜色，用于错误提示
  final Color error;
  
  /// 错误颜色上的文字颜色
  final Color onError;
  
  /// 错误容器颜色，用于错误提示背景
  final Color errorContainer;
  
  /// 错误容器上的文字颜色
  final Color onErrorContainer;
  
  /// 表面颜色，用于卡片和背景
  final Color surface;
  
  /// 表面上的文字颜色
  final Color onSurface;
  
  /// 最高级表面容器颜色，用于需要突出的背景
  final Color surfaceContainerHighest;
  
  /// 表面变体上的文字颜色
  final Color onSurfaceVariant;
  
  /// 轮廓颜色，用于边框和分隔线
  final Color outline;
  
  /// 轮廓变体颜色，用于次要边框
  final Color outlineVariant;

  /// 创建自定义颜色实例
  /// 
  /// [seedColor] 种子颜色
  /// [primary] 主要颜色
  /// [onPrimary] 主要颜色上的文字颜色
  /// [primaryContainer] 主要容器颜色
  /// [onPrimaryContainer] 主要容器上的文字颜色
  /// [secondary] 次要颜色
  /// [onSecondary] 次要颜色上的文字颜色
  /// [secondaryContainer] 次要容器颜色
  /// [onSecondaryContainer] 次要容器上的文字颜色
  /// [tertiary] 第三颜色
  /// [onTertiary] 第三颜色上的文字颜色
  /// [tertiaryContainer] 第三容器颜色
  /// [onTertiaryContainer] 第三容器上的文字颜色
  /// [error] 错误颜色
  /// [onError] 错误颜色上的文字颜色
  /// [errorContainer] 错误容器颜色
  /// [onErrorContainer] 错误容器上的文字颜色
  /// [surface] 表面颜色
  /// [onSurface] 表面上的文字颜色
  /// [surfaceContainerHighest] 最高级表面容器颜色
  /// [onSurfaceVariant] 表面变体上的文字颜色
  /// [outline] 轮廓颜色
  /// [outlineVariant] 轮廓变体颜色
  const CustomColors({
    required this.seedColor,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  /// 从ColorScheme创建CustomColors实例
  /// 
  /// [scheme] Flutter的ColorScheme实例
  /// [seed] 种子颜色
  factory CustomColors.fromColorScheme(ColorScheme scheme, Color seed) {
    return CustomColors(
      seedColor: seed,
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      secondaryContainer: scheme.secondaryContainer,
      onSecondaryContainer: scheme.onSecondaryContainer,
      tertiary: scheme.tertiary,
      onTertiary: scheme.onTertiary,
      tertiaryContainer: scheme.tertiaryContainer,
      onTertiaryContainer: scheme.onTertiaryContainer,
      error: scheme.error,
      onError: scheme.onError,
      errorContainer: scheme.errorContainer,
      onErrorContainer: scheme.onErrorContainer,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      surfaceContainerHighest: scheme.surfaceContainerHighest,
      onSurfaceVariant: scheme.onSurfaceVariant,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
    );
  }
}

/// 应用主题类，提供主题相关的工具方法和预设颜色
class AppTheme {
  /// 预设的种子颜色列表，用于用户选择主题颜色
  static const List<Color> presetSeedColors = [
    Color(0xFF6750A4), // 紫色
    Color(0xFF0061A4), // 蓝色
    Color(0xFF006E1C), // 绿色
    Color(0xFFBA1A1A), // 红色
    Color(0xFF984061), // 粉色
    Color(0xFF7C5800), // 橙色
    Color(0xFF006A6A), // 青色
    Color(0xFF4758A9), // 靛蓝色
    Color(0xFF7D5260), // 棕色
    Color(0xFF006494), // 深蓝色
  ];

  /// 创建应用主题
  ///
  /// [colorScheme] 颜色方案
  /// [useMaterial3] 是否使用Material 3
  /// [fontFamily] 字体系列
  ///
  /// 返回配置好的ThemeData实例
  static ThemeData createTheme({
    required ColorScheme colorScheme,
    required bool useMaterial3,
    String? fontFamily,
  }) {
    // Windows平台强制使用微软雅黑字体，其他平台使用系统默认字体
    final effectiveFontFamily = Platform.isWindows ? 'Microsoft YaHei' : fontFamily;

    // 统一的文本主题，确保跨平台字体一致�?
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
        fontFamily: effectiveFontFamily,
      ),
    );

    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: effectiveFontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainer,
      
      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      
      // 悬浮按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // 导航栏主题
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: colorScheme.surfaceTint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: effectiveFontFamily,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            fontFamily: effectiveFontFamily,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      
      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface, fontFamily: effectiveFontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      //  elevated按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 轮廓按钮主题
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      
      // 底部弹窗主题
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      
      //  snackbar主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface, fontFamily: effectiveFontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      
      // 列表项主题
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
