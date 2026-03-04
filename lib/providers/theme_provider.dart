import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

/// 应用主题模式枚举
/// 
/// - system: 跟随系统主题
/// - light: 浅色主题
/// - dark: 深色主题
enum AppThemeMode { system, light, dark }

/// 主题设置类，包含所有主题相关的配置
class ThemeSettings {
  /// 主题模式
  final AppThemeMode themeMode;
  
  /// 种子颜色，用于生成颜色方案
  final Color? seedColor;
  
  /// 是否使用动态颜色（Material You）
  final bool useDynamicColor;
  
  /// 是否使用Material 3
  final bool useMaterial3;
  
  /// 是否使用自定义字体
  final bool useCustomFont;

  /// 创建主题设置实例
  /// 
  /// [themeMode] 主题模式，默认为系统主题
  /// [seedColor] 种子颜色，默认为null
  /// [useDynamicColor] 是否使用动态颜色，默认为true
  /// [useMaterial3] 是否使用Material 3，默认为true
  /// [useCustomFont] 是否使用自定义字体，默认为false
  const ThemeSettings({
    this.themeMode = AppThemeMode.system,
    this.seedColor,
    this.useDynamicColor = true,
    this.useMaterial3 = true,
    this.useCustomFont = false,
  });

  /// 创建主题设置的副本，可选择性修改部分属性
  /// 
  /// [themeMode] 主题模式
  /// [seedColor] 种子颜色
  /// [useDynamicColor] 是否使用动态颜色
  /// [useMaterial3] 是否使用Material 3
  /// [useCustomFont] 是否使用自定义字体
  /// [clearSeedColor] 是否清除种子颜色
  /// 
  /// 返回修改后的ThemeSettings实例
  ThemeSettings copyWith({
    AppThemeMode? themeMode,
    Color? seedColor,
    bool? useDynamicColor,
    bool? useMaterial3,
    bool? useCustomFont,
    bool clearSeedColor = false,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: clearSeedColor ? null : (seedColor ?? this.seedColor),
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      useCustomFont: useCustomFont ?? this.useCustomFont,
    );
  }
}

/// 主题通知器，管理主题设置的状态
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  /// 存储键：主题模式
  static const String _keyThemeMode = 'theme_mode';
  
  /// 存储键：种子颜色
  static const String _keySeedColor = 'seed_color';
  
  /// 存储键：是否使用动态颜色
  static const String _keyUseDynamicColor = 'use_dynamic_color';
  
  /// 存储键：是否使用Material 3
  static const String _keyUseMaterial3 = 'use_material3';
  
  /// 存储键：是否使用自定义字体
  static const String _keyUseCustomFont = 'use_custom_font';

  /// 创建主题通知器实例
  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  /// 从SharedPreferences加载主题设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final seedColorValue = prefs.getInt(_keySeedColor);
    final useDynamicColor = prefs.getBool(_keyUseDynamicColor) ?? true;
    final useMaterial3 = prefs.getBool(_keyUseMaterial3) ?? true;
    final useCustomFont = prefs.getBool(_keyUseCustomFont) ?? false;

    state = ThemeSettings(
      themeMode: AppThemeMode.values[themeModeIndex],
      seedColor: seedColorValue != null ? Color(seedColorValue) : null,
      useDynamicColor: useDynamicColor,
      useMaterial3: useMaterial3,
      useCustomFont: useCustomFont,
    );
  }

  /// 设置主题模式
  /// 
  /// [mode] 主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  /// 设置种子颜色
  /// 
  /// [color] 种子颜色，null表示使用默认颜色
  Future<void> setSeedColor(Color? color) async {
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setInt(_keySeedColor, color.toARGB32());
    } else {
      await prefs.remove(_keySeedColor);
    }
    state = state.copyWith(seedColor: color, clearSeedColor: color == null);
  }

  /// 设置是否使用动态颜色
  /// 
  /// [value] 是否使用动态颜色
  Future<void> setUseDynamicColor(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDynamicColor, value);
    state = state.copyWith(useDynamicColor: value);
  }

  /// 设置是否使用Material 3
  /// 
  /// [value] 是否使用Material 3
  Future<void> setUseMaterial3(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseMaterial3, value);
    state = state.copyWith(useMaterial3: value);
  }

  /// 设置是否使用自定义字体
  /// 
  /// [value] 是否使用自定义字体
  Future<void> setUseCustomFont(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseCustomFont, value);
    state = state.copyWith(useCustomFont: value);
  }

  /// 获取Flutter的ThemeMode
  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// 主题设置的Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});

/// 颜色方案的Provider，根据主题设置生成
/// 
/// [dynamicColorScheme] 动态颜色方案（Material You）
final colorSchemeProvider = Provider.family<ColorScheme, ColorScheme?>((ref, dynamicColorScheme) {
  final settings = ref.watch(themeProvider);
  
  if (settings.useDynamicColor && dynamicColorScheme != null) {
    return dynamicColorScheme;
  }
  
  final seedColor = settings.seedColor ?? AppTheme.presetSeedColors.first;
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: dynamicColorScheme?.brightness ?? Brightness.light,
  );
});

/// 主题数据的Provider，根据主题设置和颜色方案生成
/// 
/// [dynamicColorScheme] 动态颜色方案（Material You）
final themeDataProvider = Provider.family<ThemeData, ColorScheme?>((ref, dynamicColorScheme) {
  final settings = ref.watch(themeProvider);
  final colorScheme = ref.watch(colorSchemeProvider(dynamicColorScheme));
  
  return AppTheme.createTheme(
    colorScheme: colorScheme,
    useMaterial3: settings.useMaterial3,
    fontFamily: settings.useCustomFont ? 'OPPOSans' : null,
  );
});
