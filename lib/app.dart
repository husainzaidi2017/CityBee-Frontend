import 'package:flutter/material.dart';

import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// Root widget: wires the theme to the router.
class CityBeeApp extends StatelessWidget {
  const CityBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
