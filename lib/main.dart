import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/scheduled_broadcast_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/scheduled_broadcast_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化应用版本号（从包信息获取）
  await AppConstants.initialize();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // CI can inject API keys via --dart-define or environment variables.
  }

  await notificationServiceProvider.initialize();
  await notificationServiceProvider.createNotificationChannel();

  await scheduledBroadcastServiceProvider.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleBroadcasts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleBroadcasts();
    }
  }

  Future<void> _scheduleBroadcasts() async {
    final settings = ref.read(scheduledBroadcastProvider);
    await scheduledBroadcastServiceProvider.scheduleBroadcasts(settings);
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    ref.listen<ScheduledBroadcastSettings>(scheduledBroadcastProvider, (
      previous,
      next,
    ) {
      if (previous != next) {
        scheduledBroadcastServiceProvider.scheduleBroadcasts(next);
      }
    });

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return FutureBuilder<ColorScheme?>(
          future: _getBypassedColorScheme(lightDynamic, themeSettings.useDynamicColor),
          builder: (context, snapshot) {
            final ColorScheme? finalLightDynamic = snapshot.data ?? lightDynamic;
            
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            if (themeSettings.useDynamicColor && finalLightDynamic != null) {
              lightColorScheme = finalLightDynamic;
              // Generate a proper dark scheme
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: finalLightDynamic.primary,
                brightness: Brightness.dark,
              );
              debugPrint(
                '[DynamicColor] Using system dynamic colors. Primary: ${finalLightDynamic.primary}',
              );
            } else {
              final seedColor =
                  themeSettings.seedColor ?? AppTheme.presetSeedColors.first;
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.dark,
              );
              debugPrint('[DynamicColor] Using seed color: $seedColor');
            }

            // 根据是否使用A屏黑主题调整深色颜色方案
            final finalDarkColorScheme = themeSettings.useAmoledBlack
                ? AppTheme.createAmoledBlackScheme(darkColorScheme)
                : darkColorScheme;

            return MaterialApp(
              title: '轻氧天气',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh', 'CN'),
                Locale('en', 'US'),
              ],
              theme: AppTheme.createTheme(
                colorScheme: lightColorScheme,
                useMaterial3: themeSettings.useMaterial3,
              ),
              darkTheme: AppTheme.createTheme(
                colorScheme: finalDarkColorScheme,
                useMaterial3: themeSettings.useMaterial3,
                isAmoledBlack: themeSettings.useAmoledBlack,
              ),
              themeMode: themeNotifier.flutterThemeMode,
              builder: (context, child) {
                if (appSettings.predictiveBackEnabled) {
                  return PredictiveBackGestureHandler(child: child!);
                }
                return child!;
              },
              home: const MainScreen(),
            );
          },
        );
      },
    );
  }

  /// 针对 ColorOS 等系统的动态取色绕过逻辑
  Future<ColorScheme?> _getBypassedColorScheme(ColorScheme? dynamic, bool enabled) async {
    if (!enabled || dynamic == null) return null;
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    // 直接尝试获取壁纸颜色，绕过系统限制
    debugPrint('[DynamicColor] Attempting native bypass to get wallpaper color...');
    try {
      const channel = MethodChannel('com.echoran.pureweather/wallpaper');
      final int? colorInt = await channel.invokeMethod<int>('getWallpaperPrimaryColor');
      if (colorInt != null) {
        final color = Color(colorInt);
        debugPrint('[DynamicColor] Native bypass successful. Extracted color: $color');
        return ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
        );
      }
    } catch (e) {
      debugPrint('[DynamicColor] Native bypass failed: $e');
    }
    return null;
  }
}

class PredictiveBackGestureHandler extends StatefulWidget {
  final Widget child;

  const PredictiveBackGestureHandler({super.key, required this.child});

  @override
  State<PredictiveBackGestureHandler> createState() =>
      _PredictiveBackGestureHandlerState();
}

class _PredictiveBackGestureHandlerState
    extends State<PredictiveBackGestureHandler> {
  @override
  Widget build(BuildContext context) {
    // Predictive back logic is typically handled at the Navigator level or via specific platform channels.
    // This wrapper ensures the subtree is correctly positioned.
    return widget.child;
  }
}
