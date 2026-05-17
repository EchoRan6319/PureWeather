import 'package:flutter/material.dart';
import 'aurora_gradient_scheme.dart';

@immutable
class AppUiTokens extends ThemeExtension<AppUiTokens> {
  final Color cardBackground;
  final Color cardBorder;
  final Color selectedBackground;
  final Color selectedBorder;
  final Color selectedForeground;
  final Color dangerBackground;
  final Color dangerBorder;
  final Color divider;
  final Color pressedOverlay;

  const AppUiTokens({
    required this.cardBackground,
    required this.cardBorder,
    required this.selectedBackground,
    required this.selectedBorder,
    required this.selectedForeground,
    required this.dangerBackground,
    required this.dangerBorder,
    required this.divider,
    required this.pressedOverlay,
  });

  factory AppUiTokens.fromColorScheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return AppUiTokens(
      // Translucent glass cards let the Aurora gradient show through
      cardBackground: colorScheme.surfaceContainerHigh.withValues(
        alpha: isDark ? 0.84 : 0.88,
      ),
      cardBorder: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.48 : 0.56,
      ),
      selectedBackground: colorScheme.secondaryContainer.withValues(
        alpha: isDark ? 0.82 : 0.88,
      ),
      selectedBorder: colorScheme.secondary.withValues(
        alpha: isDark ? 0.76 : 0.84,
      ),
      selectedForeground: colorScheme.onSecondaryContainer,
      dangerBackground: colorScheme.errorContainer.withValues(
        alpha: isDark ? 0.72 : 0.82,
      ),
      dangerBorder: colorScheme.error.withValues(alpha: isDark ? 0.78 : 0.66),
      divider: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.6),
      pressedOverlay: colorScheme.primary.withValues(alpha: 0.08),
    );
  }

  @override
  AppUiTokens copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? selectedBackground,
    Color? selectedBorder,
    Color? selectedForeground,
    Color? dangerBackground,
    Color? dangerBorder,
    Color? divider,
    Color? pressedOverlay,
  }) {
    return AppUiTokens(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      selectedForeground: selectedForeground ?? this.selectedForeground,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      divider: divider ?? this.divider,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
    );
  }

  @override
  AppUiTokens lerp(ThemeExtension<AppUiTokens>? other, double t) {
    if (other is! AppUiTokens) {
      return this;
    }
    return AppUiTokens(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      selectedBackground: Color.lerp(
        selectedBackground,
        other.selectedBackground,
        t,
      )!,
      selectedBorder: Color.lerp(selectedBorder, other.selectedBorder, t)!,
      selectedForeground: Color.lerp(
        selectedForeground,
        other.selectedForeground,
        t,
      )!,
      dangerBackground: Color.lerp(
        dangerBackground,
        other.dangerBackground,
        t,
      )!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
    );
  }
}

@immutable
class WeatherContrastColors {
  final Color accent;
  final Color foreground;
  final Color muted;
  final Color divider;

  const WeatherContrastColors({
    required this.accent,
    required this.foreground,
    required this.muted,
    required this.divider,
  });
}

extension AppThemeContext on BuildContext {
  AppUiTokens get uiTokens {
    final theme = Theme.of(this);
    return theme.extension<AppUiTokens>() ??
        AppUiTokens.fromColorScheme(theme.colorScheme);
  }

  WeatherContrastColors weatherContrastColorsFor(int? weatherCode) {
    final theme = Theme.of(this);
    final colorScheme = theme.colorScheme;

    if (weatherCode == null) {
      return WeatherContrastColors(
        accent: colorScheme.primary,
        foreground: colorScheme.onSurface,
        muted: colorScheme.onSurfaceVariant,
        divider: colorScheme.outline,
      );
    }

    final useLightForeground = WeatherGradientScheme.prefersLightForeground(
      weatherCode,
      isDark: theme.brightness == Brightness.dark,
    );

    return WeatherContrastColors(
      accent: useLightForeground
          ? Colors.white.withValues(alpha: 0.94)
          : colorScheme.primary,
      foreground: useLightForeground
          ? Colors.white.withValues(alpha: 0.94)
          : colorScheme.onSurface,
      muted: useLightForeground
          ? Colors.white.withValues(alpha: 0.72)
          : colorScheme.onSurfaceVariant,
      divider: useLightForeground
          ? Colors.white.withValues(alpha: 0.42)
          : colorScheme.outline,
    );
  }
}

/// 应用主题类，提供主题相关的工具方法
class AppTheme {
  /// 创建 Aurora UI 主题 — 玻璃质感、半透明、无阴影
  static ThemeData createTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final glassBg = colorScheme.surfaceContainerHigh.withValues(
      alpha: isDark ? 0.84 : 0.88,
    );
    final glassBorder = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.48 : 0.56,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        AppUiTokens.fromColorScheme(colorScheme),
      ],
      // Transparent scaffold lets Aurora gradient show through
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar — translucent glass
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Cards — glass panels, zero elevation
      cardTheme: CardThemeData(
        color: glassBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),

      // FAB — glass
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer.withValues(
          alpha: isDark ? 0.7 : 0.8,
        ),
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // NavigationBar — Aurora glass, no Material 3 pill indicator
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withValues(
          alpha: isDark ? 0.50 : 0.65,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            fontFamily: fontFamily,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 22);
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 22,
          );
        }),
      ),

      // Chips — translucent
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.6,
        ),
        selectedColor: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Input fields — glass fill
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.4 : 0.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
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

      // ElevatedButton — glass with primary tint
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(
            alpha: isDark ? 0.8 : 0.9,
          ),
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // FilledButton — Aurora glass (not Material filled)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(
            alpha: isDark ? 0.7 : 0.75,
          ),
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // OutlinedButton — glass border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // BottomSheet — glass top surface
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface.withValues(
          alpha: isDark ? 0.85 : 0.90,
        ),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Dialog — glass panel
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(
          alpha: isDark ? 0.85 : 0.90,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // SnackBar — glass floating
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface.withValues(alpha: 0.85),
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.secondaryContainer.withValues(
          alpha: 0.6,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Switch
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

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
