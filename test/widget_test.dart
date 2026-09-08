import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localgo/app.dart';
import 'package:localgo/data/repositories/auth_repository.dart';
import 'package:localgo/data/repositories/business_repository.dart';
import 'package:localgo/data/repositories/city_repository.dart';
import 'package:localgo/data/repositories/offer_repository.dart';
import 'package:localgo/data/repositories/place_repository.dart';
import 'package:localgo/data/repositories/profile_repository.dart';
import 'package:localgo/providers/app_providers.dart';

void main() {
  /// The app boots against API repositories in production; the widget test
  /// overrides them with the in-memory mocks so it stays hermetic (no
  /// network, no Supabase init) while exercising the real UI tree.
  ProviderScope withMockRepositories() => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          cityRepositoryProvider.overrideWithValue(MockCityRepository()),
          businessRepositoryProvider
              .overrideWithValue(MockBusinessRepository()),
          offerRepositoryProvider.overrideWithValue(MockOfferRepository()),
          placeRepositoryProvider.overrideWithValue(MockPlaceRepository()),
          profileRepositoryProvider
              .overrideWithValue(MockProfileRepository()),
        ],
        child: const CityBeeApp(),
      );

  testWidgets('App boots through splash and renders the Home tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(withMockRepositories());

    // Splash shows the brand + tagline first.
    expect(find.text("Discover What's Around You"), findsOneWidget);

    // Advance past the splash hold (~700 ms) so navigation to Home runs.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 2));

    // Home screen sections are present.
    expect(find.text('Explore Near You'), findsOneWidget);
    expect(find.text('Offers Near You'), findsOneWidget);
    expect(find.text('Popular Near You'), findsOneWidget);

    // Bottom navigation tabs.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
