import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await notificationServiceProvider.initialize();
  await notificationServiceProvider.createNotificationChannel();
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (themeSettings.useDynamicColor && lightDynamic != null) {
          lightColorScheme = lightDynamic;
          darkColorScheme = darkDynamic ?? lightDynamic;
        } else {
          final seedColor = themeSettings.seedColor ?? AppTheme.presetSeedColors.first;
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: '轻氧天气',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.createTheme(
            colorScheme: lightColorScheme,
            useMaterial3: themeSettings.useMaterial3,
          ),
          darkTheme: AppTheme.createTheme(
            colorScheme: darkColorScheme,
            useMaterial3: themeSettings.useMaterial3,
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
  State<PredictiveBackGestureHandler> createState() => _PredictiveBackGestureHandlerState();
}

class _PredictiveBackGestureHandlerState extends State<PredictiveBackGestureHandler>
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
