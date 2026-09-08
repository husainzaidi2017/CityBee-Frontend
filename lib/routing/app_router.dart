import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/businesses/presentation/business_detail_screen.dart';
import '../features/businesses/presentation/business_listing_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/explore/presentation/place_detail_screen.dart';
import '../features/home/presentation/all_categories_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/offers/presentation/offer_detail_screen.dart';
import '../features/offers/presentation/offers_screen.dart';
import '../features/profile/presentation/about_screen.dart';
import '../features/profile/presentation/contact_support_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/favorites_screen.dart';
import '../features/profile/presentation/faq_screen.dart';
import '../features/profile/presentation/legal_screen.dart';
import '../features/profile/presentation/more_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/services/presentation/services_screen.dart';
import '../features/shell/presentation/main_shell.dart';

/// App navigation graph.
///
/// The splash route starts the app, then hands off to the tab shell.
/// Tab branches live inside a StatefulShellRoute so each tab keeps its
/// scroll position; detail routes are pushed above the shell so system back
/// and the AppBar back button pop them one at a time.
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
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
      path: '/categories',
      builder: (_, __) => const AllCategoriesScreen(),
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
    GoRoute(
      path: '/profile/edit',
      builder: (_, __) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (_, __) => const ContactSupportScreen(),
    ),
    GoRoute(
      path: '/faq',
      builder: (_, __) => const FaqScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (_, __) => const AboutScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const LegalScreen.privacy(),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, __) => const LegalScreen.terms(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
