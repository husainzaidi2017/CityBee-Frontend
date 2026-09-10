import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/skeleton.dart';
import 'providers/app_providers.dart';
import 'routing/app_router.dart';

/// Root widget: wires the theme to the router and activates the Supabase
/// session listener (session restore, token refresh, deep-link callback
/// completion — see [authSessionListenerProvider]).
class CityBeeApp extends ConsumerStatefulWidget {
  const CityBeeApp({super.key});

  @override
  ConsumerState<CityBeeApp> createState() => _CityBeeAppState();
}

class _CityBeeAppState extends ConsumerState<CityBeeApp> {
  @override
  void initState() {
    super.initState();
    // Touch the listener provider so it starts observing auth events once
    // the widget tree mounts (kept alive for the app's lifetime).
    ref.read(authSessionListenerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // One shared shimmer controller for every skeleton in the app.
      builder: (context, child) => Shimmer(child: child ?? const SizedBox.shrink()),
    );
  }
}
