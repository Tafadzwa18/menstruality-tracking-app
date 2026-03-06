import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/models.dart';
import 'screens/main_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MenstrualityApp(),
    ),
  );
}

class MenstrualityApp extends StatefulWidget {
  const MenstrualityApp({super.key});

  @override
  State<MenstrualityApp> createState() => _MenstrualityAppState();
}

class _MenstrualityAppState extends State<MenstrualityApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app state 
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await context.read<AppState>().init();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isInitialized) {
      return MaterialApp(
        title: 'Menstruality Tracker',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Menstruality Tracker',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: appState.isLoggedIn ? const MainScreen() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
