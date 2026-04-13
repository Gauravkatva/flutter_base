import 'package:flutter/material.dart';
import 'package:my_appp/core/theme/civic_theme.dart';
import 'package:my_appp/l10n/l10n.dart';
import 'package:my_appp/presentation/civic_tracker_app.dart';

/// Main application widget.
///
/// Configures Material 3 theme and localization for the Civic Issue Tracker.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Issue Tracker',
      debugShowCheckedModeBanner: false,

      // Material 3 theme with accessibility optimizations
      theme: CivicTheme.lightTheme,
      darkTheme: CivicTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Entry point with BLoC providers
      home: const CivicTrackerApp(),
    );
  }
}
