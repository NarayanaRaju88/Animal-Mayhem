import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/gameplay/game_screen.dart';
import '../features/home/home_screen.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Root Flutter application.
///
/// Owns Material 3 theming and navigation only. Gameplay lives in Flame,
/// not in widgets.
class AnimalMayhemApp extends StatelessWidget {
  const AnimalMayhemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: <String, WidgetBuilder>{
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.game: (_) => const GameScreen(),
      },
    );
  }
}
