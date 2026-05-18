import 'package:flutter/material.dart';
import 'package:paddy_scan/core/constants/app_colors.dart' as palette;
import 'package:paddy_scan/core/constants/theme_colors.dart';
import 'package:paddy_scan/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'home_page.dart'; // original
import 'home_page_v3.dart' as v3; // Option 3: viewfinder + dot grid + brackets
import 'history_page.dart';
import '../screens/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _historyKey = GlobalKey<HistoryPageState>();

  // 🔀 Swap to test designs:
  //   const HomePage()      → original
  //   const v1.HomePage()   → Option 1: logo card centrepiece + frosted buttons
  //   const v2.HomePage()   → Option 2: full-page watermark behind all content
  late final List<Widget> _pages = [
    const v3.HomePage(),
    HistoryPage(key: _historyKey),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _restoreTab();
  }

  Future<void> _restoreTab() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('last_tab') ?? 0;
    if (saved != 0 && mounted) setState(() => _selectedIndex = saved);
  }

  Future<void> _saveTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_tab', index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tc = ThemeColors.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          _saveTab(i);
          if (i == 1) _historyKey.currentState?.refresh();
        },
        backgroundColor: tc.card,
        indicatorColor: palette.AppColors.primary.withValues(alpha: 0.30),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon:
                Icon(Icons.document_scanner_outlined, color: tc.iconUnselected),
            selectedIcon:
                const Icon(Icons.document_scanner, color: Colors.white),
            label: l10n.navScan,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: tc.iconUnselected),
            selectedIcon: const Icon(Icons.history, color: Colors.white),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: tc.iconUnselected),
            selectedIcon: const Icon(Icons.settings, color: Colors.white),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
