import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/location_service.dart';
import '../data/repositories/business_repository.dart';
import '../data/repositories/city_repository.dart';
import '../data/repositories/offer_repository.dart';
import '../data/repositories/place_repository.dart';
import '../data/repositories/service_repository.dart';
import '../domain/models/app_category.dart';
import '../domain/models/business.dart';
import '../domain/models/city.dart';
import '../domain/models/offer.dart';
import '../domain/models/place.dart';
import '../domain/models/service_item.dart';
import '../domain/models/user_profile.dart';

// ── Repositories (swap mock → supabase implementations here) ─────────────
final cityRepositoryProvider = Provider<CityRepository>((ref) => MockCityRepository());
final businessRepositoryProvider = Provider<BusinessRepository>((ref) => MockBusinessRepository());
final offerRepositoryProvider = Provider<OfferRepository>((ref) => MockOfferRepository());
final placeRepositoryProvider = Provider<PlaceRepository>((ref) => MockPlaceRepository());
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) => MockServiceRepository());
final locationServiceProvider = Provider((ref) => const LocationService());

// ── Cities & selected city ───────────────────────────────────────────────
final citiesProvider = FutureProvider<List<City>>((ref) async {
  return ref.watch(cityRepositoryProvider).getCities();
});

/// The currently selected city — every content provider reads this so all
/// screens react to a city switch.
class CityController extends Notifier<City> {
  @override
  City build() => ref.watch(citiesProvider).maybeWhen(
        data: (cities) => cities.first,
        orElse: () => const City(
          id: 'moradabad',
          name: 'Moradabad',
          state: 'Uttar Pradesh',
          nickname: 'Peetal Nagri',
          defaultArea: 'Civil Lines, Moradabad',
          latitude: 28.8386,
          longitude: 78.7733,
        ),
      );

  void select(City city) => state = city;

  /// Best-effort "use my location": silently keeps the current city when
  /// permission is denied or no known city is nearby.
  Future<bool> useMyLocation() async {
    final service = ref.read(locationServiceProvider);
    final cities = await ref.read(citiesProvider.future);
    try {
      final position = await service.getCurrentPosition();
      if (position == null) return false;
      final nearest = service.nearestCity(position, cities);
      if (nearest == null) return false;
      state = nearest;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final selectedCityProvider = NotifierProvider<CityController, City>(CityController.new);

// ── Profile (mock until Supabase Auth) ───────────────────────────────────
const _mockProfile = UserProfile(
  name: 'Amit Sharma',
  handle: '@amit.moradabad',
  levelTitle: 'Level 3 Pioneer',
  topPercent: 'Top 5% Saver',
  savedAmount: '₹2,450',
  bookmarkCount: 12,
  reviewsGiven: 5,
  avatarImage: 'https://picsum.photos/seed/localgo-avatar/200/200',
);

final userProfileProvider = Provider<UserProfile>((ref) => _mockProfile);

// ── Favorites ────────────────────────────────────────────────────────────
/// Bookmarked business ids + saved offer ids in one notifier so the More
/// screen and favorite hearts stay in sync.
class FavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    state = state.contains(id) ? {...state}..remove(id) : {...state, id};
  }

  bool includes(String id) => state.contains(id);
}

final favoritesProvider =
    NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

// ── Catalog content ──────────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<AppCategory>>((ref) async {
  ref.watch(selectedCityProvider);
  return ref.watch(cityRepositoryProvider).getCategories();
});

final businessesByCategoryProvider =
    FutureProvider.autoDispose.family<List<Business>, String>((ref, categoryId) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(businessRepositoryProvider).getByCategory(categoryId, cityId: city.id);
});

final popularBusinessesProvider = FutureProvider.autoDispose
    .family<List<Business>, PopularFilter>((ref, filter) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(businessRepositoryProvider).getPopular(cityId: city.id, filter: filter);
});

final businessByIdProvider =
    FutureProvider.autoDispose.family<Business?, String>((ref, id) async {
  return ref.watch(businessRepositoryProvider).getById(id);
});

final offersByTagProvider =
    FutureProvider.autoDispose.family<List<Offer>, String>((ref, tag) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(offerRepositoryProvider).getOffers(cityId: city.id, tag: tag);
});

final offersCountProvider = FutureProvider<int>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(offerRepositoryProvider).countAll(cityId: city.id);
});

final offerByIdProvider =
    FutureProvider.autoDispose.family<Offer?, String>((ref, id) async {
  return ref.watch(offerRepositoryProvider).getById(id);
});

final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(placeRepositoryProvider).getPlaces(cityId: city.id);
});

final placeByIdProvider =
    FutureProvider.autoDispose.family<Place?, String>((ref, id) async {
  return ref.watch(placeRepositoryProvider).getById(id);
});

final foodsProvider = FutureProvider.autoDispose<List<FoodHighlight>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(placeRepositoryProvider).getFoods(cityId: city.id);
});

final cityGuideProvider = FutureProvider.autoDispose<CityGuide>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(placeRepositoryProvider).getGuide(cityId: city.id);
});

final servicesProvider = FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(serviceRepositoryProvider).getServices(cityId: city.id);
});

final eventServicesProvider =
    FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(serviceRepositoryProvider).getEventServices(cityId: city.id);
});

final legalServiceProvider = FutureProvider.autoDispose<ServiceItem>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(serviceRepositoryProvider).getLegalService(cityId: city.id);
});

final helplinesProvider = FutureProvider.autoDispose<List<Helpline>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(serviceRepositoryProvider).getHelplines(cityId: city.id);
});

final specialistCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final city = ref.watch(selectedCityProvider);
  return ref.watch(serviceRepositoryProvider).specialistCount(cityId: city.id);
});
