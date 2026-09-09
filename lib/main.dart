import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'domain/models/user_profile.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Auth (email OTP / Google ID-token sign-in). Data flows through
  // the NestJS API; this client exists to sign in and mint access tokens.
  // Auth links (email deep links / OAuth) return to citybee://auth-callback.
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Warm-start the profile cache so the More/Profile screens render the
  // user's name instantly on app open (no 0.5s blank flash) — the API
  // refresh runs right after and updates the state.
  UserProfile? cachedProfile;
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('citybee.profile');
    if (raw != null && Supabase.instance.client.auth.currentSession != null) {
      cachedProfile = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  } catch (_) {
    // Corrupt cache → fall back to the blank default.
  }

  runApp(
    ProviderScope(
      overrides: [cachedUserProfileProvider.overrideWithValue(cachedProfile)],
      child: const CityBeeApp(),
    ),
  );
}
