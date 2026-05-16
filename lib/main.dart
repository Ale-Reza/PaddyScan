import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project specific imports
import 'core/di/injection_container.dart' as di;
import 'presentation/app.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/blocs/home/home_event.dart';

// ✅ Global notifiers — accessible everywhere
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.dark);

// ✅ Top-level function — not nested inside main
Future<void> _loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final isUrdu = prefs.getBool('urdu_enabled') ?? false;
  localeNotifier.value = isUrdu ? const Locale('ur') : const Locale('en');
  final isDark = prefs.getBool('dark_mode') ?? true;
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved locale before app starts
  await _loadLocale(); // ✅ now called correctly

  // Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) print('✅ Config loaded');
  } catch (e) {
    if (kDebugMode) print('⚠️ Running with default values: $e');
  }

  // Initialize Dependency Injection
  await di.init();

  // Global Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) =>
              di.sl<HomeBloc>()..add(const CheckServerConnection()),
        ),
      ],
      child: const App(),
    ),
  );
}
