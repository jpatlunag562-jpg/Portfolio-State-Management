import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/network_monitor_provider.dart';
import 'screens/activity_one_screen.dart';
import 'screens/activity_two_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/network_monitor_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => NetworkMonitorProvider()),
      ],
      child: const LabCompilationApp(),
    ),
  );
}

class LabCompilationApp extends StatelessWidget {
  final NetworkMonitorProvider? networkMonitorProvider;

  const LabCompilationApp({super.key, this.networkMonitorProvider});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    final app = MaterialApp(
      title: 'Lab Compilation App',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appState.primarySeedColor,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appState.primarySeedColor,
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeDashboardScreen(),
        '/activity1': (context) => const ActivityOneScreen(),
        '/activity2': (context) => const ActivityTwoScreen(),
        '/network-monitor': (context) => const NetworkMonitorScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );

    try {
      Provider.of<NetworkMonitorProvider>(context, listen: false);
      return app;
    } catch (_) {
      return ChangeNotifierProvider(
        create: (_) => networkMonitorProvider ?? NetworkMonitorProvider(),
        child: app,
      );
    }
  }
}
