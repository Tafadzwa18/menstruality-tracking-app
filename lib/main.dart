import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme.dart';
import 'core/models.dart';
import 'core/sync_service.dart';
import 'screens/main_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Load environment variables
      await dotenv.load(fileName: ".env");

      // 2. Initialize Supabase with timeout
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      ).timeout(const Duration(seconds: 8));

      // 3. Initialize local database / sync
      await SyncService().init().timeout(const Duration(seconds: 10));

      // 4. Initialize app state
      await context.read<AppState>().init().timeout(const Duration(seconds: 10));

    } catch (e) {
      // Log error but DO NOT block UI
      debugPrint("Startup error: $e");
    } finally {
      // Always remove splash screen
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isInitialized) {
      return MaterialApp(
        title: 'Menstruality Tracker',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryPink,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Menstruality Tracker',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: appState.isLoggedIn
          ? const MainScreen()
          : const OnboardingScreen(),
    );
  }
}