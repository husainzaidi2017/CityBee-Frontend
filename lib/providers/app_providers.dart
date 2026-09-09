import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide OtpChannel;

import '../core/network/api_client.dart';
import '../core/services/location_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_supabase.dart';
import '../data/repositories/business_repository.dart';
import '../data/repositories/city_repository.dart';
import '../data/repositories/offer_repository.dart';
import '../data/repositories/place_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/api/api_business_repository.dart';
import '../data/repositories/api/api_city_repository.dart';
import '../data/repositories/api/api_offer_repository.dart';
import '../data/repositories/api/api_place_repository.dart';
import '../data/repositories/api/api_profile_repository.dart';
import '../domain/models/app_category.dart';
import '../domain/models/app_notification.dart';
import '../domain/models/business.dart';
import '../domain/models/citybee_location.dart';
import '../domain/models/city.dart';
import '../domain/models/offer.dart';
import '../domain/models/place.dart';
import '../domain/models/service_item.dart';
import '../domain/models/user_profile.dart';

// ── Repositories (API-backed; swap back to mocks for offline dev) ─────────
final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => SupabaseAuthRepository());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(
      tokenProvider: () => ref.read(authRepositoryProvider).accessToken,
    ));
final cityRepositoryProvider = Provider<CityRepository>(
    (ref) => ApiCityRepository(ref.watch(apiClientProvider)));
final businessRepositoryProvider = Provider<BusinessRepository>(
    (ref) => ApiBusinessRepository(ref.watch(apiClientProvider)));
final offerRepositoryProvider = Provider<OfferRepository>(
    (ref) => ApiOfferRepository(ref.watch(apiClientProvider)));
final placeRepositoryProvider = Provider<PlaceRepository>(
    (ref) => ApiPlaceRepository(ref.watch(apiClientProvider)));
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) => MockServiceRepository());
final locationServiceProvider = Provider((ref) => const LocationService());
final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => ApiProfileRepository(
        ref.watch(apiClientProvider), ref.watch(authRepositoryProvider)));

// ── Authentication (guest browsing is always allowed) ────────────────────
/// Whether the user has an active session. Login is never mandatory —
/// the whole app works as a guest with `false`.
///
/// State follows the Supabase Auth session (login, logout, token refresh,
/// restore on app start); the session listener below keeps it in sync.
class AuthController extends Notifier<bool> {
  @override
  bool build() {
    // Supabase persists sessions locally — reopening the app stays logged in.
    return ref.read(authRepositoryProvider).isSignedIn;
  }

  Future<void> sendOtp(String email, {OtpChannel channel = OtpChannel.email}) =>
      ref.read(authRepositoryProvider).sendOtp(email, channel: channel);

  Future<void> verifyOtp(String email, String otp) async {
    await ref.read(authRepositoryProvider).verifyOtp(email, otp);
    state = true;
    _syncProfile();
  }

  Future<void> signInWithGoogle() async {
    await ref.read(authRepositoryProvider).signInWithGoogle();
    state = true;
    _syncProfile();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    state = false;
  }

  /// Session-event sync (token refresh, remote sign-out) — external
  /// listener uses this since `state` is protected.
  void update(bool signedIn) => state = signedIn;

  /// Best-effort profile sync after sign-in: GET /users/me upserts the
  /// public.users row (auth uid, name, email, avatar) server-side,
  /// idempotently, and refreshes the in-app profile.
  Future<void> _syncProfile() async {
    try {
      await ref.read(profileRepositoryProvider).getProfile();
    } catch (_) {
      // Profile sync is best-effort; discovery works regardless.
    }
  }
}

final authStateProvider = NotifierProvider<AuthController, bool>(AuthController.new);

/// Keeps auth state in sync with Supabase session events (token refresh,
/// remote sign-out, expiry) — no second auth system.
final authSessionListenerProvider = Provider<AuthSessionSync>((ref) {
  try {
    final subscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final controller = ref.read(authStateProvider.notifier);
      controller.update(event.session != null);
    });
    ref.onDispose(subscription.cancel);
    return AuthSessionSync(subscription);
  } catch (_) {
    // Listener is a safety net; the controller reads session state directly.
    return const AuthSessionSync(null);
  }
});

/// Handle to the Supabase session subscription (cancels with the provider).
class AuthSessionSync {
  const AuthSessionSync(this.subscription);

  // ignore: unused_field
  final Object? subscription;
}

// ── Cities (CityBee reference data) & Google location search ─────────────
final citiesProvider = FutureProvider<List<City>>((ref) async {
  return ref.watch(cityRepositoryProvider).getCities();
});

/// Google Places location search (debounced by the caller).
final citySearchProvider =
    FutureProvider.autoDispose.family<List<CitySuggestion>, String>((ref, query) async {
  return ref.watch(cityRepositoryProvider).searchCities(query);
});

// ── Selected location (single source of truth) ───────────────────────────
/// The user's selected Google location. Coordinates drive every discovery
/// provider; the display name drives every header. Selecting a location
/// NEVER creates a CityBee city — it persists locally (guests) and on the
/// user profile (signed in).
class LocationController extends Notifier<CityBeeLocation> {
  static const _prefsKey = 'citybee.selectedLocation';

  /// First-run default: the city CityBee launched with. Overridden by the
  /// persisted selection or GPS on first interaction.
  static const _defaultLocation = CityBeeLocation(
    displayName: 'Moradabad',
    state: 'Uttar Pradesh',
    country: 'India',
    countryCode: 'IN',
    latitude: 28.8386,
    longitude: 78.7733,
    locality: 'Moradabad',
  );

  @override
  CityBeeLocation build() {
    _restore();
    return _defaultLocation;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final location = CityBeeLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // Ignore corrupted entries.
      if (location.displayName.isNotEmpty && location.latitude != 0) {
        state = location;
      }
    } catch (_) {
      // Corrupt storage → keep the default.
    }
  }

  Future<void> select(CityBeeLocation location) async {
    if (location.displayName.isEmpty) return;
    state = location;

    // Local persistence (guests included).
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(location.toJson()));
    } catch (_) {}

    // Backend sync for signed-in users (best effort).
    final auth = ref.read(authRepositoryProvider);
    if (!auth.isSignedIn) return;
    try {
      await ref
          .read(apiClientProvider)
          .patch('/users/me', body: {'selectedLocation': location.toProfilePatch()});
    } catch (_) {}
  }

  /// "Use my current location": GPS → reverse geocode via the backend
  /// (Google) → select. No CityBee city is created.
  Future<bool> useMyLocation() async {
    final service = ref.read(locationServiceProvider);
    try {
      final position = await service.getCurrentPosition();
      if (position == null) return false;
      final location = await ref
          .read(cityRepositoryProvider)
          .reverseGeocode(position.latitude, position.longitude);
      if (location == null || location.displayName.isEmpty) return false;
      await select(location);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final selectedLocationProvider =
    NotifierProvider<LocationController, CityBeeLocation>(LocationController.new);

// ── Profile ──────────────────────────────────────────────────────────────
/// Editable user profile. [save] persists through the repository (API when
/// signed in; local guest profile otherwise).
class UserProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Hydrate asynchronously from the API when a session exists.
    final repo = ref.read(profileRepositoryProvider);
    if (ref.read(authRepositoryProvider).isSignedIn) {
      repo.getProfile().then((profile) => state = profile);
    }
    return const UserProfile(
      name: 'Amit Sharma',
      handle: '@amit.moradabad',
      email: 'amit.sharma@example.com',
      phone: '+91 98765 43210',
      levelTitle: 'Level 3 Pioneer',
      topPercent: 'Top 5% Saver',
      savedAmount: '₹2,450',
      bookmarkCount: 12,
      reviewsGiven: 5,
      avatarImage: 'https://picsum.photos/seed/localgo-avatar/200/200',
    );
  }

  Future<void> save(UserProfile profile) async {
    final saved = await ref.read(profileRepositoryProvider).saveProfile(profile);
    state = saved;
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(UserProfileController.new);

// ── Favorites ────────────────────────────────────────────────────────────
/// Bookmarked business ids + saved offer ids in one notifier so the More
/// screen and favorite hearts stay in sync.
///
/// Local-first: the set always updates instantly (guests keep favorites
/// locally); when signed in, toggles also sync to the backend best-effort
/// and the set hydrates from GET /favorites on login.
class FavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final auth = ref.read(authRepositoryProvider);
    if (auth.isSignedIn) {
      _hydrate();
    }
    return {};
  }

  Future<void> _hydrate() async {
    try {
      final data = await ref.read(apiClientProvider).get('/favorites');
      if (data is List) {
        final slugs = data
            .map((e) {
              if (e is! Map<String, dynamic>) return null;
              final business = e['business'] as Map<String, dynamic>?;
              final place = e['place'] as Map<String, dynamic>?;
              return business?['id']?.toString() ?? place?['id']?.toString();
            })
            .whereType<String>()
            .toSet();
        state = slugs;
      }
    } catch (_) {
      // Keep local favorites when the sync fails.
    }
  }

  void toggle(String id, {String? uuid, String type = 'business'}) {
    final next = {...state};
    final wasFavorite = next.contains(id);
    wasFavorite ? next.remove(id) : next.add(id);
    state = next;

    final auth = ref.read(authRepositoryProvider);
    if (!auth.isSignedIn || uuid == null) return;
    // Best-effort backend sync; local state stays authoritative on failure.
    final body = {'${type}Id': uuid};
    if (wasFavorite) {
      ref
          .read(apiClientProvider)
          .delete('/favorites/by-entity', body: body)
          .catchError((_) => null);
    } else {
      ref
          .read(apiClientProvider)
          .post('/favorites', body: body)
          .catchError((_) => null);
    }
  }

  bool includes(String id) => state.contains(id);
}

final favoritesProvider =
    NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

// ── Catalog content (coordinate-based; backend expands radius per category) ──
final categoriesProvider = FutureProvider<List<AppCategory>>((ref) async {
  ref.watch(selectedLocationProvider);
  return ref.watch(cityRepositoryProvider).getCategories();
});

final businessesByCategoryProvider =
    FutureProvider.autoDispose.family<List<Business>, String>((ref, categoryId) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(businessRepositoryProvider).getByCategory(
        categoryId,
        lat: location.latitude,
        lng: location.longitude,
      );
});

final popularBusinessesProvider = FutureProvider.autoDispose
    .family<List<Business>, PopularFilter>((ref, filter) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(businessRepositoryProvider).getPopular(
        filter: filter,
        lat: location.latitude,
        lng: location.longitude,
      );
});

final businessByIdProvider =
    FutureProvider.autoDispose.family<Business?, String>((ref, id) async {
  return ref.watch(businessRepositoryProvider).getById(id);
});

final offersByTagProvider =
    FutureProvider.autoDispose.family<List<Offer>, String>((ref, tag) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(offerRepositoryProvider).getOffers(
        tag: tag,
        lat: location.latitude,
        lng: location.longitude,
      );
});

final offersCountProvider = FutureProvider<int>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(offerRepositoryProvider).countAll(
        lat: location.latitude,
        lng: location.longitude,
      );
});

final offerByIdProvider =
    FutureProvider.autoDispose.family<Offer?, String>((ref, id) async {
  return ref.watch(offerRepositoryProvider).getById(id);
});

final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(placeRepositoryProvider).getPlaces(
        lat: location.latitude,
        lng: location.longitude,
      );
});

final placeByIdProvider =
    FutureProvider.autoDispose.family<Place?, String>((ref, id) async {
  return ref.watch(placeRepositoryProvider).getById(id);
});

final foodsProvider = FutureProvider.autoDispose<List<FoodHighlight>>((ref) async {
  return ref.watch(placeRepositoryProvider).getFoods();
});

final cityGuideProvider = FutureProvider.autoDispose<CityGuide>((ref) async {
  return ref.watch(placeRepositoryProvider).getGuide();
});

final servicesProvider = FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(serviceRepositoryProvider).getServices(cityId: location.displayName);
});

final eventServicesProvider =
    FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(serviceRepositoryProvider).getEventServices(cityId: location.displayName);
});

final legalServiceProvider = FutureProvider.autoDispose<ServiceItem>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(serviceRepositoryProvider).getLegalService(cityId: location.displayName);
});

final helplinesProvider = FutureProvider.autoDispose<List<Helpline>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(serviceRepositoryProvider).getHelplines(cityId: location.displayName);
});

final specialistCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  return ref.watch(serviceRepositoryProvider).specialistCount(cityId: location.displayName);
});

// ── Search ───────────────────────────────────────────────────────────────
final searchResultsProvider =
    FutureProvider.autoDispose.family<List<Business>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  return ref.watch(businessRepositoryProvider).search(query);
});

// ── Notifications (API inbox when signed in) ─────────────────────────────
final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  if (!ref.watch(authStateProvider)) return const <AppNotification>[];
  final data = await ref.watch(apiClientProvider).get('/notifications');
  if (data is! List) return const <AppNotification>[];
  return data
      .map((e) => e is Map<String, dynamic> ? _notification(e) : null)
      .whereType<AppNotification>()
      .toList();
});

AppNotification _notification(Map<String, dynamic> json) {
  final payloadJson =
      json['payload'] is Map<String, dynamic> ? json['payload'] as Map<String, dynamic> : const <String, dynamic>{};
  final payload = NotificationPayload.fromData(payloadJson);
  final (icon, color) = switch (payload.target) {
    NotificationTarget.offer => (Icons.local_offer_rounded, 0xFFF4691F),
    NotificationTarget.business => (Icons.verified, 0xFF0E6B4F),
    NotificationTarget.place => (Icons.location_on_outlined, 0xFFE23A2E),
    _ => (Icons.notifications_active_outlined, 0xFF1A73E8),
  };
  return AppNotification(
    id: json['id']?.toString() ?? '',
    icon: icon,
    colorValue: color,
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? '',
    time: _relativeTime(json['createdAt']?.toString()),
    payload: payload,
  );
}

String _relativeTime(String? isoDate) {
  if (isoDate == null) return '';
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
