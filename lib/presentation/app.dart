import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:paddy_scan/main.dart';
import 'screens/splash_screen.dart';
import 'screens/result_page.dart';
import 'screens/main_shell.dart';
import '../core/constants/app_theme.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => const SplashScreen(),
  redirect: (context, state) {
    if (state.matchedLocation == '/') return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) {
        final resultData = state.extra as Map<String, dynamic>;
        return ResultPage(data: resultData);
      },
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'PaddyScan',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: _router,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ur', ''),
              ],
            );
          },
        );
      },
    );
  }
}
