import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// Root widget: wires the theme to the router.
class LocalGoApp extends StatelessWidget {
  const LocalGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LocalGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
