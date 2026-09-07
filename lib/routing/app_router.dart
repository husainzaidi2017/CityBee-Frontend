import 'package:go_router/go_router.dart';

import '../features/businesses/presentation/business_detail_screen.dart';
import '../features/businesses/presentation/business_listing_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/explore/presentation/place_detail_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/offers/presentation/offer_detail_screen.dart';
import '../features/offers/presentation/offers_screen.dart';
import '../features/profile/presentation/favorites_screen.dart';
import '../features/profile/presentation/more_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/services/presentation/services_screen.dart';
import '../features/shell/presentation/main_shell.dart';

/// App navigation graph.
///
/// Tab branches live inside a StatefulShellRoute so each tab keeps its
/// scroll position; detail routes push above the shell.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/offers', builder: (_, __) => const OffersScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/services', builder: (_, __) => const ServicesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => BusinessListingScreen(
        categoryId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/business/:id',
      builder: (context, state) => BusinessDetailScreen(
        businessId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/offer/:id',
      builder: (context, state) => OfferDetailScreen(
        offerId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) => PlaceDetailScreen(
        placeId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/search',
      builder: (_, __) => const SearchScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
  ],
);
