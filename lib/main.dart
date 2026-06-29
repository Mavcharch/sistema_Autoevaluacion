import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'models/programming_language.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CodeJudgeApp());
}

class CodeJudgeApp extends StatefulWidget {
  const CodeJudgeApp({super.key});

  @override
  State<CodeJudgeApp> createState() => _CodeJudgeAppState();
}

class _CodeJudgeAppState extends State<CodeJudgeApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null && mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> _setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeJudge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      onGenerateRoute: _onGenerateRoute,
      home: _MainShell(
        themeMode: _themeMode,
        onThemeChanged: _setDarkMode,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/results') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => ResultsScreen(
          code: args['code'] as String,
          language: args['language'] as ProgrammingLanguage,
        ),
      );
    }
    if (settings.name == '/settings') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode: args['isDarkMode'] as bool,
          onThemeChanged: args['onThemeChanged'] as ValueChanged<bool>,
        ),
      );
    }
    return null;
  }
}

/// Shell principal con la barra de navegación inferior.
class _MainShell extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;

  const _MainShell({
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  void _goToEditor() {
    setState(() => _currentIndex = 1);
  }

  void _openSettings() {
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    Navigator.of(context).pushNamed(
      '/settings',
      arguments: {
        'isDarkMode': isDark,
        'onThemeChanged': widget.onThemeChanged,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onStartEvaluation: _goToEditor,
        onOpenSettings: _openSettings,
      ),
      const EditorScreen(),
      const HistoryScreen(),
      const DashboardScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
