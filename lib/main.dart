import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/scheduled_broadcast_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/scheduled_broadcast_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env文件不存在，尝试从系统环境变量中读取
    Map<String, String> envVars = Platform.environment;
    for (var entry in envVars.entries) {
      if (entry.key.startsWith('QWEATHER_') || 
          entry.key.startsWith('CAIYUN_') || 
          entry.key.startsWith('AMAP_') || 
          entry.key.startsWith('DEEPSEEK_')) {
        dotenv.env[entry.key] = entry.value;
      }
    }
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
      setState(() {});
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
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (themeSettings.useDynamicColor && lightDynamic != null) {
          lightColorScheme = lightDynamic;
          darkColorScheme = darkDynamic ?? lightDynamic;
          debugPrint(
            '[DynamicColor] Using dynamic colors: primary=${lightDynamic.primary}',
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
            fontFamily: themeSettings.useCustomFont ? 'OPPOSans' : null,
          ),
          darkTheme: AppTheme.createTheme(
            colorScheme: darkColorScheme,
            useMaterial3: themeSettings.useMaterial3,
            fontFamily: themeSettings.useCustomFont ? 'OPPOSans' : null,
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
    extends State<PredictiveBackGestureHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
